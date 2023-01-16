// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { BaseHuffTest } from "test/BaseHuffTest.sol";
import { IOwnedMirror } from "../src/interfaces/IOwnedMirror.sol";
import { IEchoer } from "./helpers/IEchoer.sol";
import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";

contract DoppelgangerTest is BaseHuffTest {
    IOwnedMirror mirror;

    error Address(address);

    function setUp() public override {
        super.setUp();
        mirror = deployOwnedMirror(address(hello), address(this));
    }

    function testDeploy() public {
        address doppelganger = deployDoppelganger(address(mirror));
        assertEq(doppelganger.code, address(hello).code);
        assertEq(IEchoer(doppelganger).echo(), hello.echo());
        mirror.setMirrored(address(world));
        doppelganger = deployDoppelganger(address(mirror));
        assertEq(doppelganger.code, address(world).code);
        assertEq(IEchoer(doppelganger).echo(), world.echo());
    }

    function testCreate2SameAddress() public {
        bytes memory revert1;
        bytes memory revert2;
        try this.create2Helper(hello) {
            fail("should have reverted");
        } catch (bytes memory reason) {
            revert1 = reason;
        }
        try this.create2Helper(world) {
            fail("should have reverted");
        } catch (bytes memory reason) {
            revert2 = reason;
        }
        assertEq(revert1, revert2, "reverts do not match");
    }

    /**
     * @dev Helper function
     */
    function create2Helper(IEchoer target) external {
        mirror.setMirrored(address(target));

        bytes memory doppelgangerCreationCode = HuffDeployer.config().creation_code("Doppelganger"); //hex"60146021600c393636363636515afa363d11163d36363e363d9161001f57fd5bf3";
        bytes memory initCode = abi.encodePacked(doppelgangerCreationCode, mirror);

        address doppelganger;
        assembly {
            doppelganger := create2(0, add(initCode, 0x20), mload(initCode), 0)
        }
        revert Address(doppelganger);
    }
}
