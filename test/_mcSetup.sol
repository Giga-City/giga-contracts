// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_deploySetup.sol";

contract MCSetup is DeploySetup {

  function setUp() public virtual override {
      super.setUp();

      // ****** BASICS ****** //
      
      // Metadata
      memoryChip.setBaseURI(baseURI);
      memoryChip.setURISuffix(URISuffix);

      // Minting related information
      memoryChip.setMaxMintPerAddress(mcMintPerAddy);
      memoryChip.setMintPrice(mintPrice);

      // ****** WHITELIST ****** //

      // Compute leaves.
      bytes32 leaf1 = keccak256(abi.encodePacked(user1));
      bytes32 leaf2 = keccak256(abi.encodePacked(user2));

      // First level: combine leaf1 and leaf2.
      bytes32 merkleRoot = _hashPair(leaf1, leaf2);

      // Setting the merkle root
      memoryChip.setCorpoRoot(merkleRoot);

      // ****** Setup GC ****** //
      memoryChip.setGigaCityContract(address(gigaCity));
  }

  function getProof(address user) public view returns (bytes32[] memory proof) {
    // Compute leaves.
    bytes32 leaf1 = keccak256(abi.encodePacked(user1));
    bytes32 leaf2 = keccak256(abi.encodePacked(user2));
    
    // For a two-leaf tree, the proof for user1 is just [leaf2]
    // and for user2 it is [leaf1].
    if (user == user1) {
        proof = new bytes32[](1);
        proof[0] = leaf2;
    } else if (user == user2) {
        proof = new bytes32[](1);
        proof[0] = leaf1;
    } else {
        // If the user is not whitelisted, return an empty proof.
        proof = new bytes32[](0);
    }
  }

  function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
    return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
  }
}