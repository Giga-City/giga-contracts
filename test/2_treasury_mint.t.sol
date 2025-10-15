// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./0_deploy.t.sol";

// =============================================================
//                   MINT TREASURY TESTS
// =============================================================

contract MintTreasuryTest is DeploySetup {
    function setUp() public override {
        super.setUp();
    }

    function testMintTreasuryToZeroAddressReverts() public {
        vm.expectRevert(GigaCity.InvalidAddress.selector);
        gigaCity.mintTreasury(address(0), 1);
    }

    function testMintTreasurySuccessfully() public {
        gigaCity.mintTreasury(user1, 5);
        assertEq(gigaCity.balanceOf(user1), 5, "Should mint 5 tokens to user1");
        assertEq(gigaCity.ownerOf(1), user1, "Token 1 should belong to user1");
        assertEq(gigaCity.ownerOf(5), user1, "Token 5 should belong to user1");
    }

    function testMintTreasuryRespectSupplyCap() public {
        vm.expectRevert(GigaCity.SupplyExceeded.selector);
        gigaCity.mintTreasury(owner, supplyCap + 1);
    }

    function testMintTreasuryExactSupplyCap() public {
        gigaCity.mintTreasury(owner, supplyCap);
        assertEq(gigaCity.balanceOf(owner), supplyCap, "Should mint exactly to supply cap");
    }

    function testMintTreasuryOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.mintTreasury(user1, 1);
    }
}
