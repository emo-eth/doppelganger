// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { BaseHuffTest } from "./BaseHuffTest.sol";
import { IOwnedMirror } from "../src/interfaces/IOwnedMirror.sol";
import { IEchoer } from "./helpers/IEchoer.sol";
import { Hello } from "./helpers/Hello.sol";
import { World } from "./helpers/World.sol";

contract OwnedMirrorTest is BaseHuffTest {
    function testDeploy() public {
        IOwnedMirror mirror = deployOwnedMirror(address(hello), address(this));
        assertEq(mirror.getMirrored(), address(hello));
        assertEq(mirror.owner(), address(this));
    }

    function testSetMirror() public {
        IOwnedMirror mirror = deployOwnedMirror(address(hello), address(this));
        mirror.setMirrored(address(world));
        assertEq(mirror.getMirrored(), address(world));
    }

    function testSetMirror_setOwner() public {
        IOwnedMirror mirror = deployOwnedMirror(address(hello), address(this));
        mirror.setOwner(address(world));
        assertEq(mirror.owner(), address(world));
    }

    function testSetMirror_onlyOwner() public {
        IOwnedMirror mirror = deployOwnedMirror(address(hello), address(this));
        vm.startPrank(makeAddr("not owner"));
        vm.expectRevert();
        mirror.setMirrored(address(world));
    }

    function testFallback() public {
        IOwnedMirror mirror = deployOwnedMirror(address(hello), address(this));
        (bool succ, bytes memory ret) = address(mirror).call("");
        assertTrue(succ, "fallback failed");
        assertEq(ret, address(hello).code);

        mirror.setMirrored(address(world));
        (succ, ret) = address(mirror).call("");
        assertTrue(succ, "fallback failed");
        assertEq(ret, address(world).code);
    }
}
