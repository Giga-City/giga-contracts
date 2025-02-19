// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_deploySetup.sol";

contract MCSetup is DeploySetup {

  function setUp() public virtual override {
      super.setUp();

      // ****** BASICS ****** //
      
      // Metadata
      memoryChip.setBaseURI('https://test.com/');
      memoryChip.setURISuffix('.json');

      // Minting related information
      memoryChip.setMaxMintPerAddress(mcMintPerAddy);
      memoryChip.setMintPrice(0.01 ether);

      // ****** WHITELIST ****** //

      // Compute leaves.
      bytes32 leaf1 = keccak256(abi.encodePacked(user1));
      bytes32 leaf2 = keccak256(abi.encodePacked(user2));

      // First level: combine leaf1 and leaf2.
      bytes32 merkleRoot = _hashPair(leaf1, leaf2);

      // Setting the merkle root
      memoryChip.setCorpoRoot(merkleRoot);

      // ****** Setup GC ****** //
      memoryChip.setGigaCityContract(address(memoryChip));
  }

  function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
    return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
  }
}