// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { BaseHuffTest } from "./BaseHuffTest.sol";
import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";

contract SnapshotTest is BaseHuffTest {
    bytes ownedMirrorInitCode;
    bytes doppelgangerInitCode;
    address mirror1;

    function setUp() public override {
        super.setUp();
        ownedMirrorInitCode = HuffDeployer.config().with_args(abi.encode(address(hello), address(this)))
            .creation_code_with_args("OwnedMirror");
        doppelgangerInitCode = HuffDeployer.config().with_args(
            abi.encodePacked(0x9bF8d24F77AAadBcE79cbcd35C38e7E7890d1b64)
        ).creation_code_with_args("Doppelganger");
        mirror1 = address(deployOwnedMirror(address(hello), address(this)));
    }

    function test_snapshotDeployOwnedMirror() public {
        bytes memory initCode = ownedMirrorInitCode;
        uint256 gas = gasleft();
        address mirror2;
        assembly {
            mirror2 := create2(0, add(initCode, 0x20), mload(initCode), 0)
        }
        emit log_named_uint("Gas", gas - gasleft());
    }

    function test_snapshotDeployDoppelganger() public {
        bytes memory initCode = doppelgangerInitCode;
        uint256 gas = gasleft();
        address doppelganger1;
        assembly {
            doppelganger1 := create2(0, add(initCode, 0x20), mload(initCode), 0)
        }
        emit log_named_uint("Gas", gas - gasleft());
    }
}
