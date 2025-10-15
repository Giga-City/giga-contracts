// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./0_deploy.t.sol";

contract GigaCityChipTest is DeploySetup {
    function setUp() public override {
        super.setUp();
        gigaCity.toggleCorpoMint();
    }

    // =============================================================
    //                        TEST CORPO
    // =============================================================

    function testCantMintCorpoOverSupply() public {
        gigaCity.mintTreasury(owner, supplyCap - 1);
        bytes32[] memory proof1 = getProof(user1);

        vm.startPrank(user1);
        vm.expectRevert(GigaCity.SupplyExceeded.selector);
        gigaCity.mintCorpo{value: 0.02 ether}(proof1, 2);
        vm.stopPrank();
    }

    function testCantMintCorpoIfMintNotOpen() public {
        bytes32[] memory proof1 = getProof(user1);
        // We turn the corpo mint off since it is turned
        // on in setup
        gigaCity.toggleCorpoMint();
        // We cant mint yet
        vm.startPrank(user1);
        vm.expectRevert(GigaCity.CorpoMintClosed.selector);
        gigaCity.mintCorpo{value: 0.01 ether}(proof1, 1);
        vm.stopPrank();
    }

    function testCantMintWithoutCash() public {
        bytes32[] memory proof1 = getProof(user1);

        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(GigaCity.NoCashForMint.selector);
        gigaCity.mintCorpo(proof1, 1);
        vm.stopPrank();
    }

    function testCantMintWithWrongValue() public {
        bytes32[] memory proof1 = getProof(user1);

        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(GigaCity.NoCashForMint.selector);
        gigaCity.mintCorpo{value: 0.01 ether}(proof1, 2);
        vm.stopPrank();
    }

    function testCantMintWithSomebodyElsesProof() public {
        bytes32[] memory proof2 = getProof(user2);

        vm.startPrank(user1);
        // We cant with somebody elses proof
        vm.expectRevert(GigaCity.CantMintCorpo.selector);
        gigaCity.mintCorpo{value: 0.01 ether}(proof2, 1);
        vm.stopPrank();
    }

    function testCorpoMintPerAddy() public {
        bytes32[] memory proof1 = getProof(user1);
        bytes32[] memory proof2 = getProof(user2);

        vm.startPrank(user1);
        // We can mint here
        gigaCity.mintCorpo{value: 0.01 ether}(proof1, 1);
        gigaCity.mintCorpo{value: 0.01 ether}(proof1, 1);
        // We cant mint another
        vm.expectRevert(GigaCity.AddressQuantityExceeded.selector);
        gigaCity.mintCorpo{value: 0.01 ether}(proof1, 1);
        // We cant mint over maxPerAddy
        vm.stopPrank();

        vm.startPrank(user2);
        // We can mint here
        gigaCity.mintCorpo{value: 0.02 ether}(proof2, 2);
        // Making sure we cant mint another
        vm.expectRevert(GigaCity.AddressQuantityExceeded.selector);
        gigaCity.mintCorpo{value: 0.01 ether}(proof2, 1);
        // We cant mint over maxPerAddy
        vm.stopPrank();
    }

        function testCorpoMintRefundsExcessETH() public {
        bytes32[] memory proof1 = getProof(user1);
        uint256 initialBalance = user1.balance;

        // Send more ETH than needed (0.05 instead of 0.01)
        vm.prank(user1);
        gigaCity.mintCorpo{value: 0.05 ether}(proof1, 1);

        // User should be refunded excess
        uint256 finalBalance = user1.balance;
        assertEq(finalBalance, initialBalance - 0.01 ether, "Should refund excess ETH");
        assertEq(gigaCity.balanceOf(user1), 1, "Should have minted 1 token");
    }

        function testCorpoMintExactPayment() public {
        bytes32[] memory proof2 = getProof(user2);
        uint256 initialBalance = user2.balance;

        // Send exact amount
        vm.prank(user2);
        gigaCity.mintCorpo{value: 0.02 ether}(proof2, 2);

        uint256 finalBalance = user2.balance;
        assertEq(finalBalance, initialBalance - 0.02 ether, "Should pay exact amount");
        assertEq(gigaCity.balanceOf(user2), 2, "Should have minted 2 tokens");
    }
}