// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IEchoer } from "./IEchoer.sol";

contract World is IEchoer {
    function echo() external pure returns (string memory) {
        return "World!";
    }
}
