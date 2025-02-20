
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_mcSetup.sol";

contract MemoryChipTest is MCSetup {
    function setUp() public override {
        super.setUp();
        memoryChip.toggleBotMint();
    }

    // =============================================================
    //                        TEST BOT
    // =============================================================

    function testCantMintBotIfMintNotOpen() public {
        // We turn the bot mint off since it is turned
        // on in setup
        memoryChip.toggleBotMint();
        // We cant mint yet
        vm.startPrank(user1);
        vm.expectRevert(MemoryChip.NoBotMintYet.selector);
        memoryChip.mintBot(1);
        vm.stopPrank();
    }

    function testCantMintBotWithoutCash() public {
        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(MemoryChip.NoCashForMint.selector);
        memoryChip.mintBot(1);
        vm.stopPrank();
    }

    function testCantMintBotWithWrongValue() public {
        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(MemoryChip.NoCashForMint.selector);
        memoryChip.mintBot{value: 0.01 ether}(2);
        vm.stopPrank();
    }

    function testCantMintBotOverSupply() public {
        memoryChip.mintTreasury(owner, mcSupplyCap - 1);

        vm.startPrank(user1);
        vm.expectRevert(MemoryChip.SupplyExceeded.selector);
        memoryChip.mintBot{value: 0.04 ether}(2);
        vm.stopPrank();
    }

    function testCantMintBotPerAddy() public {
        vm.startPrank(user1);
        memoryChip.mintBot{value: 0.02 ether}(2);
        vm.expectRevert(MemoryChip.AddressQuantityExceeded.selector);
        memoryChip.mintBot{value: 0.01 ether}(1);
        vm.stopPrank();
    }
}