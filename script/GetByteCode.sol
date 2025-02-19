// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/memorychip.sol";

contract InitHashTest is Test {
    function testGetInitHash() public pure {
        bytes memory bytecode = type(MemoryChip).creationCode;
        bytes32 hash = keccak256(bytecode);
        console.logBytes(bytecode);
        console.log('===============');
        console.logBytes32(hash);
    }
}