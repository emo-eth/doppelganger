// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { BaseCreate2Script, console2 } from "create2-scripts/BaseCreate2Script.s.sol";
import { IOwnedMirror } from "../src/interfaces/IOwnedMirror.sol";
import { Hello } from "../test/helpers/Hello.sol";
import { World } from "../test/helpers/World.sol";
import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";

contract DeployDopplegangers is BaseCreate2Script {
    function run() public {
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
            HuffDeployer.config().with_args(abi.encode(address(0), deployer)).creationCodeWithArgs("OwnedMirror")
        );
    }

    function configureMirror(IOwnedMirror mirror, bytes memory code) internal {
        address created = _create2IfNotDeployed(deployer, bytes32(0), code);
        mirror.setMirrored(created);
    }

    function deployDoppleganger(IOwnedMirror mirror) internal returns (address) {
        return _immutableCreate2IfNotDeployed(
            deployer,
            bytes32(0),
            HuffDeployer.config().with_args(abi.encodePacked(address(mirror))).creationCodeWithArgs("Doppleganger")
        );
    }
}
