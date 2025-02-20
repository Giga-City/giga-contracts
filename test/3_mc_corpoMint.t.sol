
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_mcSetup.sol";

contract MemoryChipTest is MCSetup {
    function setUp() public override {
        super.setUp();
        memoryChip.toggleCorpoMint();
    }

    // =============================================================
    //                        TEST CORPO
    // =============================================================

    function testCantMintCorpoOverSupply() public {
        memoryChip.mintTreasury(owner, mcSupplyCap - 1);
        bytes32[] memory proof1 = getProof(user1);

        vm.startPrank(user1);
        vm.expectRevert(MemoryChip.SupplyExceeded.selector);
        memoryChip.mintCorpo{value: 0.02 ether}(proof1, 2);
        vm.stopPrank();
    }

    function testCantMintCorpoIfMintNotOpen() public {
        bytes32[] memory proof1 = getProof(user1);
        // We turn the corpo mint off since it is turned
        // on in setup
        memoryChip.toggleCorpoMint();
        // We cant mint yet
        vm.startPrank(user1);
        vm.expectRevert(MemoryChip.NoCorpoMintYet.selector);
        memoryChip.mintCorpo{value: 0.01 ether}(proof1, 1);
        vm.stopPrank();
    }

    function testCantMintWithoutCash() public {
        bytes32[] memory proof1 = getProof(user1);

        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(MemoryChip.NoCashForMint.selector);
        memoryChip.mintCorpo(proof1, 1);
        vm.stopPrank();
    }

    function testCantMintWithWrongValue() public {
        bytes32[] memory proof1 = getProof(user1);

        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(MemoryChip.NoCashForMint.selector);
        memoryChip.mintCorpo{value: 0.01 ether}(proof1, 2);
        vm.stopPrank();
    }

    function testCantMintWithSomebodyElsesProof() public {
        bytes32[] memory proof2 = getProof(user2);

        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(MemoryChip.CantMintCorpo.selector);
        memoryChip.mintCorpo{value: 0.01 ether}(proof2, 1);
        vm.stopPrank();
    }

      function testCorpoMintPerAddy() public {
        bytes32[] memory proof1 = getProof(user1);
        bytes32[] memory proof2 = getProof(user2);

        vm.startPrank(user1);
        // We can mint here
        memoryChip.mintCorpo{value: 0.01 ether}(proof1, 1);
        memoryChip.mintCorpo{value: 0.01 ether}(proof1, 1);
        // We cant mint another
        vm.expectRevert(MemoryChip.AddressQuantityExceeded.selector);
        memoryChip.mintCorpo{value: 0.01 ether}(proof1, 1);
        // We cant mint over maxPerAddy
        vm.stopPrank();

        vm.startPrank(user2);
        // We can mint here
        memoryChip.mintCorpo{value: 0.02 ether}(proof2, 2);
        // Making sure we cant mint another
        vm.expectRevert(MemoryChip.AddressQuantityExceeded.selector);
        memoryChip.mintCorpo{value: 0.01 ether}(proof2, 1);
        // We cant mint over maxPerAddy
        vm.stopPrank();
    }
}