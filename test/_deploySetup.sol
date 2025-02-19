// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../src/filthypeasants.sol";
import "../src/gigacity.sol";
import "../src/memorychip.sol";

contract DeploySetup is Test {
    FilthyPeasants public filthyPeasants;
    GigaCity public gigaCity;
    MemoryChip public memoryChip;

    address public owner;

    address public user1;
    address public user2;
    address public user3;

    uint256 public mcSupplyCap = 10;    
    uint256 public mcMintPerAddy = 2;

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

        // Deploy MyContract with an initial value and the owner.
        filthyPeasants = new FilthyPeasants('FitlyPeasants', 'Filthy', 0, 333, 10);
        memoryChip = new MemoryChip(mcSupplyCap, 1);
        gigaCity = new GigaCity(address(memoryChip));
    }
}