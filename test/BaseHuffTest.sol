// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";
import { IOwnedMirror } from "../src/interfaces/IOwnedMirror.sol";
import { IEchoer } from "./helpers/IEchoer.sol";
import { Hello } from "./helpers/Hello.sol";
import { World } from "./helpers/World.sol";
import { Test } from "forge-std/Test.sol";

contract BaseHuffTest is Test {
    IEchoer hello;
    IEchoer world;

    function setUp() public virtual {
        hello = IEchoer(new Hello());
        world = IEchoer(new World());
    }

    function deployDoppelganger(address mirror) internal returns (address) {
        return HuffDeployer.config().with_args(abi.encodePacked(mirror)).deploy("Doppelganger");
    }

    function deployOwnedMirror(address mirrored, address owner) internal returns (IOwnedMirror) {
        return IOwnedMirror(HuffDeployer.config().with_args(abi.encode(mirrored, owner)).deploy("OwnedMirror"));
    }
}
