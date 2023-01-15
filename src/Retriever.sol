// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Retriever {
    bytes32 retrieved;

    function setRetrieved(bytes32 _retrieved) public {
        retrieved = _retrieved;
    }

    function retrieve() public view returns (bytes32) {
        return retrieved;
    }
}
