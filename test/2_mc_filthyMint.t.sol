
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_mcSetup.sol";

contract MemoryChipTest is MCSetup {

    function setUp() public override {
        super.setUp();

        memoryChip.toggleFilthyMint();
        filthyPeasants.setPaused(false);

        vm.prank(user1);
        filthyPeasants.mint(1);

        vm.prank(user2);
        filthyPeasants.mint(1);
    }

    // Testing wether onlyOwner truly works
    function testMintTreasury() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.mintTreasury(user1, 1);

        // Testing as owner
        vm.prank(owner);
        memoryChip.mintTreasury(owner, 1);
    }

    // Within supply is part of every mint function
    // So we can test it with treasury mint only
    function testWithinSupply() public {
        // This will pass, nothing wrong with it
        memoryChip.mintTreasury(owner, 2);
        // Expect this to fail since we are going over total supply
        vm.expectRevert(MemoryChip.SupplyExceeded.selector);
        // Minus two already minted plus one above
        memoryChip.mintTreasury(owner, mcSupplyCap);
        // This should pass as it is within supply
        memoryChip.mintTreasury(owner, mcSupplyCap - 2);
    }

    // =============================================================
    //                        TEST FILTHYS
    // =============================================================

    function testCantMintFilthyIfMintNotOpen() public {
        // We turn the filthy mint off since it is turned
        // on in setup
        memoryChip.toggleFilthyMint();
        // We cant mint yet
        vm.startPrank(user1);
        vm.expectRevert(MemoryChip.NoFilthyMintYet.selector);
        memoryChip.mintFilthy(1);
        vm.stopPrank();
    }

    function testCantMintSomebodyElsesFilthy() public {
        vm.startPrank(user1);
        // This isnt our filthy peasant
        vm.expectRevert(MemoryChip.CantMintThisFilthy.selector);
        memoryChip.mintFilthy(2);
        assertEq(memoryChip.peasantMinted(2), false, "This peasant havent minted yet");
        // This is ours
        memoryChip.mintFilthy(1);
        assertEq(memoryChip.peasantMinted(1), true, "This peasant had already minted");
        vm.stopPrank();
    }

    function testCantMintSameFilthyTwice() public {
        vm.startPrank(user1);
        memoryChip.mintFilthy(1);
        assertEq(memoryChip.peasantMinted(1), true, "This peasant had already minted");
        vm.expectRevert(MemoryChip.PeasantAlreadyMinted.selector);
        memoryChip.mintFilthy(1);
        vm.stopPrank();
    }

    function testFilthyMint() public {
        // With one filthy peasant, and total cap of 10,
        // it should be possible to mint 14 with 2 peasants
        memoryChip.mintTreasury(owner, mcSupplyCap);

        vm.prank(user1);
        memoryChip.mintFilthy(1);

        // We can no longer mint
        vm.expectRevert(MemoryChip.SupplyExceeded.selector);
        memoryChip.mintTreasury(owner, 1);
        
        vm.prank(user2);
        memoryChip.mintFilthy(2);

        assertEq(memoryChip.totalPeasantsMinted(), 2, "We have minted only 2 peasants so far");
    }
}