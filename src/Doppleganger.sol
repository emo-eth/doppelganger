// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Retriever } from "./Retriever.sol";

contract Doppleganger {
    bytes32 immutable runtime;

    constructor(Retriever retriever) {
        runtime = retriever.retrieve();
    }

    function readRuntime() public view returns (bytes32) {
        return runtime;
    }
}
