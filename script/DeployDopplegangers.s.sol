// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { BaseCreate2Script, console2 } from "create2-scripts/BaseCreate2Script.s.sol";
import { Retriever } from "../src/Retriever.sol";
import { Doppleganger } from "../src/Doppleganger.sol";

contract DeployDopplegangers is BaseCreate2Script {
    function run() public {
        console2.log(vm.toString(deployer));
        runOnNetworks(this.execute, vm.envString("NETWORKS", ","));
    }

    function execute() external returns (address) {
        bytes32 toRetrieve;
        console2.log("Chain ID: ", block.chainid);
        if (block.chainid == 5) {
            toRetrieve = "goerli";
        } else {
            toRetrieve = "mumbai";
        }
        setRuntime(toRetrieve);
        return address(0);
    }

    function setRuntime(bytes32 runtime) internal {
        Retriever r = Retriever(_immutableCreate2IfNotDeployed(deployer, bytes32(0), type(Retriever).creationCode));
        vm.broadcast(deployer);
        r.setRetrieved(runtime);
        Doppleganger d = Doppleganger(
            _immutableCreate2IfNotDeployed(
                deployer, bytes32(0), abi.encodePacked(type(Doppleganger).creationCode, abi.encode(address(r)))
            )
        );
        console2.log(vm.toString(d.readRuntime()));
    }
}
