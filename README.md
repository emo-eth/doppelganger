# Doppelganger

<img src="https://user-images.githubusercontent.com/6371847/212580006-235acf82-0b59-4f67-9b07-8757470085a7.png" alt="Not To Be Reproduced (La reproduction interdite) - René Magritte" width=300 />

*Not To Be Reproduced (La reproduction interdite) - René Magritte*

Doppelganger is a proof-of-concept set of Huff smart contracts that allow for deploying arbitrary code to the same address on multiple networks using CREATE2 – inspired by [Metamorphic smart contracts](https://github.com/0age/metamorphic), but without the ability to change the code after deployment, and (hopefully) hyper-optimized for this specific use case.

## OwnedMirror.huff

The approximate Solidity interface of IOwnedMirror is as follows:
```solidity
interface IOwnedMirror {
    event OwnerUpdated(address indexed, address indexed);

    constructor(address initialMIrrored, address initialOwner)

    function getMirrored() external view returns (address);
    function setMirrored(address) external;
    function owner() external view returns (address);
    function setOwner(address) external;

    fallback() external returns (bytes memory);
}
```

OwnedMirror is an `Ownable` smart contract that contains a storage variable `MIRRORED`, which is accessed and set via the via the standard methods `getMirrored()` and `setMirrored(address)`, the latter of which is restricted to the owner of the smart contract. 

Its constructor takes two abi-encoded addresses; the first is the initial address of `MIRRORED`, and the second is the address of the initial owner.

When called with no calldata, `OwnedMirror` will return the bytecode of the account `MIRRORED` (which may be length-0).

It is possible to deterministically deploy an `OwnedMirror` contract to the same address on multiple networks by using the same `salt`, `initialMirrored`, and `initialOwner`, but, crucially, the storage variables may be updated independently on each network.

## Doppelganger.huff

During construction, `Doppelganger` reads the final 20-bytes of its initialization code and makes an empty `staticcall` to the equivalent address. Any bytes returned will become the `Doppelganger`'s runtime code. The constructor will revert if the call is unsuccessful or no bytes are returned.

This means that, in combination with an `OwnedMirror`, it's possible to deploy arbitrary bytecode to the same address on different chains using CREATE2. While not (currently?) possible to directly verify the contracts on, eg, Etherscan, if the original implementation contracts are verified, Etherscan will show the code used to verify the original implementaitons as the code for the `Doppelganger` contracts.

# Examples

Here are two different (verified) smart contracts on Goerli and Polygon Mumbai, deployed using the [ImmutableCreate2Factory](https://goerli.etherscan.io/address/0x0000000000ffe8b47b3e2130213b802212439497#code).

['Hello.sol' deployed to Goerli at 0x029e55ec380b7a043a2f0d7bc3f61708dfafa579](https://goerli.etherscan.io/address/0x029e55ec380b7a043a2f0d7bc3f61708dfafa579#code)

['World.sol' deployed to Polygon Mumbai at 0x029e55ec380b7a043a2f0d7bc3f61708dfafa579](https://mumbai.polygonscan.com/address/0x029e55ec380b7a043a2f0d7bc3f61708dfafa579#code)
