// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { BaseCreate2Script, console2 } from "create2-scripts/BaseCreate2Script.s.sol";
import { IOwnedMirror } from "../src/interfaces/IOwnedMirror.sol";
import { Hello } from "../test/helpers/Hello.sol";
import { World } from "../test/helpers/World.sol";
import { HuffConfig } from "foundry-huff/HuffConfig.sol";

contract DeployDopplegangers is BaseCreate2Script {
    function run() public {
        setUp();
        console2.log(vm.toString(deployer));
        runOnNetworks(this.execute, vm.envString("NETWORKS", ","));
    }

    function execute() external returns (address) {
        bytes memory bytecode;
        console2.log("Chain ID: ", block.chainid);
        if (block.chainid == 5) {
            bytecode = type(Hello).creationCode;
        } else {
            bytecode = type(World).creationCode;
        }
        IOwnedMirror mirror = IOwnedMirror(deployMirror());
        configureMirror(IOwnedMirror(mirror), bytecode);
        deployDoppleganger(mirror);
        return address(0);
    }

    function deployMirror() internal returns (address) {
        // deploy with mirror set to address(0)
        return _immutableCreate2IfNotDeployed(
            deployer,
            bytes32(0),
            (new HuffConfig()).with_args(abi.encode(address(0), deployer)).creationCodeWithArgs("OwnedMirror")
        );
    }

    function configureMirror(IOwnedMirror mirror, bytes memory code) internal {
        console2.log("configuring mirror");
        address created = _create2IfNotDeployed(deployer, bytes32(0), code);
        vm.broadcast(deployer);
        mirror.setMirrored(created);
    }

    function deployDoppleganger(IOwnedMirror mirror) internal returns (address) {
        console2.log("deploying doppleganger");
        return _immutableCreate2IfNotDeployed(
            deployer,
            bytes32(uint256(1)),
            (new HuffConfig()).with_args(abi.encodePacked(address(mirror))).creationCodeWithArgs("Doppleganger")
        );
    }
}
