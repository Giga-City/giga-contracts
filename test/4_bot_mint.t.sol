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

        function testBotMintRefundsExcessETH() public {
        uint256 initialBalance = user1.balance;

        // Send more ETH than needed (0.1 instead of 0.02)
        vm.prank(user1);
        gigaCity.mintBot{value: 0.1 ether}(2);

        // User should be refunded excess
        uint256 finalBalance = user1.balance;
        assertEq(finalBalance, initialBalance - 0.02 ether, "Should refund excess ETH");
        assertEq(gigaCity.balanceOf(user1), 2, "Should have minted 2 tokens");
    }

    function testBotMintExactPayment() public {
        uint256 initialBalance = user3.balance;

        // Send exact amount
        vm.prank(user3);
        gigaCity.mintBot{value: 0.01 ether}(1);

        uint256 finalBalance = user3.balance;
        assertEq(finalBalance, initialBalance - 0.01 ether, "Should pay exact amount");
        assertEq(gigaCity.balanceOf(user3), 1, "Should have minted 1 token");
    }
}