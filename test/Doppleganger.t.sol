// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { BaseHuffTest } from "test/BaseHuffTest.sol";
import { IOwnedMirror } from "../src/interfaces/IOwnedMirror.sol";
import { IEchoer } from "./helpers/IEchoer.sol";
import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";

contract DopplegangerTest is BaseHuffTest {
    IOwnedMirror mirror;

    error Address(address);

    function setUp() public override {
        super.setUp();
        mirror = deployOwnedMirror(address(hello), address(this));
    }

    function testDeploy() public {
        address doppleganger = deployDoppleganger(address(mirror));
        assertEq(doppleganger.code, address(hello).code);
        assertEq(IEchoer(doppleganger).echo(), hello.echo());
        mirror.setMirrored(address(world));
        doppleganger = deployDoppleganger(address(mirror));
        assertEq(doppleganger.code, address(world).code);
        assertEq(IEchoer(doppleganger).echo(), world.echo());
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

        bytes memory dopplegangerCreationCode = HuffDeployer.config().creationCode("Doppleganger"); //hex"60146021600c393636363636515afa363d11163d36363e363d9161001f57fd5bf3";
        bytes memory initCode = abi.encodePacked(dopplegangerCreationCode, mirror);

        address doppleganger;
        assembly {
            doppleganger := create2(0, add(initCode, 0x20), mload(initCode), 0)
        }
        revert Address(doppleganger);
    }
}
