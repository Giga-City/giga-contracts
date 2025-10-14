// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./0_deploy.t.sol";

contract GigaCityChipTest is DeploySetup {

    function setUp() public override {
        super.setUp();
    }

    // =============================================================
    //                         INFO GETTERS
    // =============================================================

    function testURIandID() public {
        gigaCity.mintTreasury(owner, 1);

        vm.expectRevert(GigaCity.TokenDoesNotExist.selector);
        gigaCity.tokenURI(0);

        gigaCity.tokenURI(1);
        assertEq(gigaCity.tokenURI(1), string.concat(baseURI,'1', URISuffix), "The expected URL should be correct");

        string memory newBaseUri = 'http://yee.co/';
        string memory newSuffix = '';

        gigaCity.setBaseURI(newBaseUri);
        gigaCity.setURISuffix(newSuffix);

        assertEq(gigaCity.tokenURI(1), string.concat(newBaseUri,'1', newSuffix), "The expected URL should be correct");
    }

    function testNoBaseURI() public {
        gigaCity.mintTreasury(owner, 1);

        string memory newBaseUri = '';
        string memory newSuffix = '';

        gigaCity.setBaseURI(newBaseUri);
        gigaCity.setURISuffix(newSuffix);

        // It should fail as empty string if no base URI provided
        assertEq(gigaCity.tokenURI(1), '', "The expected URL should be correct");
    }

    // function testSupportsInterface() public {
    //     // Should be public information
    //     vm.prank(user1);
    //     assertEq(gigaCity.supportsInterface(0x80ac58cd), true, "Should support IERC721");
    // }

    // =============================================================
    //                         GENERAL SETTERS
    // =============================================================

    function testSetMaxMintPerAddress() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.setMaxMintPerAddress(20);
        assertEq(gigaCity.maxMintPerAddress(), mintPerAddy, "Should have correctly set max mint per address");

        // Testing as owner
        vm.prank(owner);
        gigaCity.setMaxMintPerAddress(20);
        assertEq(gigaCity.maxMintPerAddress(), 20, "Should have correctly set max mint per address");
    }

    function testSetMintPrice() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.setMintPrice(0);
        assertEq(gigaCity.mintPrice(), mintPrice, "Should have correctly set mint price");

        // Testing as owner
        vm.prank(owner);
        gigaCity.setMintPrice(1 ether);
        assertEq(gigaCity.mintPrice(), 1 ether, "Should have correctly set mint price");
    }

    function testOwner() public {
        vm.prank(user1);
        // vm.expectRevert();
        assertEq(gigaCity.owner(), owner, "Owner should be the owner");
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.transferOwnership(user1);

        vm.prank(owner);
        gigaCity.transferOwnership(user1);
        assertEq(gigaCity.owner(), user1, "User1 should be the owner");
    }

    function testWithdraw() public {
        vm.deal(address(gigaCity), 1 ether);

        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.withdraw();

        assertEq(address(gigaCity).balance, 1 ether, "Contract should still have one ether");
        
        // We need to change the ownership since the owner is the contract
        vm.prank(owner);
        gigaCity.transferOwnership(user1);

        // Testing as new owner
        vm.prank(user1);
        assertEq(user1.balance, 1 ether, "Owner should have one ether");
        gigaCity.withdraw();
        assertEq(address(gigaCity).balance, 0, "Contract should have no ether");
        assertEq(user1.balance, 2 ether, "Owner should have 2 ethers");
    }

    // =============================================================
    //                         SET MINT SLOTS
    // =============================================================

    // Testing wether onlyOwner truly works
    function testToggleCorpoMint() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.toggleCorpoMint();
        assertEq(gigaCity.corpoMint(), false, "Corpo mint should be set to false");

        // Testing as owner
        vm.prank(owner);
        gigaCity.toggleCorpoMint();
        assertEq(gigaCity.corpoMint(), true, "Corpo mint should be set to true");
    }

    function testToggleBotMint() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.toggleBotMint();
        assertEq(gigaCity.botMint(), false, "Bot mint should be set to false");

        // Testing as owner
        vm.prank(owner);
        gigaCity.toggleBotMint();
        assertEq(gigaCity.botMint(), true, "Bot mint should be set to true");
    }
}

// =============================================================
//                      WITHDRAW FAILED COVERAGE
// =============================================================

// A helper contract that reverts on receiving Ether.
contract RevertReceiver  {
    // Fallback function that always reverts
    fallback() external payable {
        revert("I don't accept Ether");
    }
}

contract WithDrawTest is DeploySetup {

    function setUp() public override {
        super.setUp();
    }

        // Test a failing withdrawal:
    // When the owner is a contract that reverts on receiving Ether, the withdraw call should revert.
    function testWithdrawFailure() public {
        // Fund the gigaCity contract with 1 ether.
        vm.deal(address(gigaCity), 1 ether);

        // Deploy a helper contract that refuses to accept Ether.
        RevertReceiver revertReceiver = new RevertReceiver();

        // Transfer ownership of gigaCity to the revertReceiver.
        gigaCity.transferOwnership(address(revertReceiver));

        vm.prank(address(revertReceiver));
        vm.expectRevert(GigaCity.WithdrawlFailed.selector);
        gigaCity.withdraw();
    }

}