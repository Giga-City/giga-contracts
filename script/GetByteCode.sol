// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/memorychip.sol";
import "src/gigacity.sol";

contract InitHashTest is Test {
    function testGetInitHash() public pure {
        // Define the constructor parameter(s)
        address deployer=0x237DE2eC3D2caF5B85EFa2312EC1c0D77B4219Dc;
        address filthyAddress = 0xDE892c47562A4A383f2f88447cd3082D5a9688E4;
        address mcContract = 0x000000000000763B5B437cFC2F41249ABC045937;

        uint256 supplyCap = 9334;
        uint256 maxMint = 2;
        
        // Get the base creation (init) code
        bytes memory creationCode = type(MemoryChip).creationCode;
        
        // ABI-encode the constructor parameter(s)
        bytes memory encodedParams = abi.encode(filthyAddress, supplyCap, maxMint, deployer);
        
        // Concatenate the creation code with the encoded constructor parameters
        bytes memory bytecode = abi.encodePacked(creationCode, encodedParams);
        
        // Compute the keccak256 hash of the full init code (which now includes the parameters)
        bytes32 hash = keccak256(bytecode);

        console.log('====== MC ======');
        console.logBytes32(hash);

        // Get the base creation (init) code
        bytes memory creationCode2 = type(GigaCity).creationCode;
        // ABI-encode the constructor parameter(s)
        bytes memory encodedParams2 = abi.encode(mcContract, deployer);
        // Concatenate the creation code with the encoded constructor parameters
        bytes memory bytecode2 = abi.encodePacked(creationCode2, encodedParams2);
        // Compute the keccak256 hash of the full init code (which now includes the parameters)
        bytes32 hash2 = keccak256(bytecode2);

        console.log('====== GC ======');
        console.logBytes32(hash2);

        // bytes memory bytecode = type(MemoryChip).creationCode;
        // bytes32 hash = keccak256(bytecode);
        // console.logBytes(bytecode);
        // console.log('===============');
        // console.logBytes32(hash);
    }
}