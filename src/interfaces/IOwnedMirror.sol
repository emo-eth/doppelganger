// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IOwnedMirror {
    event OwnerUpdated(address indexed, address indexed);

    function getMirrored() external view returns (address);
    function owner() external view returns (address);
    function setMirrored(address) external;
    function setOwner(address) external;
    fallback(bytes calldata) external returns (bytes memory);
}
