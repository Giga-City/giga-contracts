// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/gigacity.sol";

contract DeploySetup is Test {
    GigaCity public gigaCity;

    address public owner;

    address public user1;
    address public user2;
    address public user3;

    uint256 public supplyCap = 10000;    
    uint256 public mintPerAddy = 2;
    uint256 public mintPrice = 0.01 ether;

    string public baseURI = 'https://test.com/';
    string public URISuffix = '.json';

    // Shared setup logic runs before every test.
    function setUp() public virtual {
        owner = address(this); // The test contract as owner.

        user1 = vm.addr(1);
        user2 = vm.addr(2);
        user3 = vm.addr(3);

        vm.deal(owner, 1 ether);
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
        vm.deal(user3, 1 ether);

        gigaCity = new GigaCity(address(owner), address(owner));

        gigaCity.setBaseURI(baseURI);
        gigaCity.setURISuffix(URISuffix);

        gigaCity.setMaxMintPerAddress(mintPerAddy);
        gigaCity.setMintPrice(mintPrice);

        // ****** WHITELIST ****** //

        // Compute leaves.
        bytes32 leaf1 = keccak256(abi.encodePacked(user1));
        bytes32 leaf2 = keccak256(abi.encodePacked(user2));

        // First level: combine leaf1 and leaf2.
        bytes32 merkleRoot = _hashPair(leaf1, leaf2);

        // Setting the merkle root
        gigaCity.setCorpoRoot(merkleRoot);
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