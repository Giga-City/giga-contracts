// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./0_deploy.t.sol";

contract GigaCityChipTest is DeploySetup {
    function setUp() public override {
        super.setUp();
        gigaCity.toggleBotMint();
    }

    // =============================================================
    //                        TEST BOT
    // =============================================================

    function testCantMintBotIfMintNotOpen() public {
        // We turn the bot mint off since it is turned
        // on in setup
        gigaCity.toggleBotMint();
        // We cant mint yet
        vm.startPrank(user1);
        vm.expectRevert(GigaCity.BotMintClosed.selector);
        gigaCity.mintBot(1);
        vm.stopPrank();
    }

    function testCantMintBotWithoutCash() public {
        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(GigaCity.NoCashForMint.selector);
        gigaCity.mintBot(1);
        vm.stopPrank();
    }

    function testCantMintBotWithWrongValue() public {
        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(GigaCity.NoCashForMint.selector);
        gigaCity.mintBot{value: 0.01 ether}(2);
        vm.stopPrank();
    }

    function testCantMintBotOverSupply() public {
        gigaCity.mintTreasury(owner, supplyCap - 1);

        vm.startPrank(user1);
        vm.expectRevert(GigaCity.SupplyExceeded.selector);
        gigaCity.mintBot{value: 0.04 ether}(2);
        vm.stopPrank();
    }

    function testCantMintBotPerAddy() public {
        vm.startPrank(user1);
        gigaCity.mintBot{value: 0.02 ether}(2);
        vm.expectRevert(GigaCity.AddressQuantityExceeded.selector);
        gigaCity.mintBot{value: 0.01 ether}(1);
        vm.stopPrank();
    }
}