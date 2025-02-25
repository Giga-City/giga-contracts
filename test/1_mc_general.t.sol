// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_mcSetup.sol";

contract MemoryChipTest is MCSetup {

    function setUp() public override {
        super.setUp();
    }

    // =============================================================
    //                         INFO GETTERS
    // =============================================================

    function testURIandID() public {
        memoryChip.mintTreasury(owner, 1);

        vm.expectRevert(MemoryChip.ChipDoesNotExist.selector);
        memoryChip.tokenURI(0);

        memoryChip.tokenURI(1);
        assertEq(memoryChip.tokenURI(1), string.concat(baseURI,'1', URISuffix), "The expected URL should be correct");

        string memory newBaseUri = 'http://yee.co/';
        string memory newSuffix = '';

        memoryChip.setBaseURI(newBaseUri);
        memoryChip.setURISuffix(newSuffix);

        assertEq(memoryChip.tokenURI(1), string.concat(newBaseUri,'1', newSuffix), "The expected URL should be correct");
    }

    function testNoBaseURI() public {
        memoryChip.mintTreasury(owner, 1);

        string memory newBaseUri = '';
        string memory newSuffix = '';

        memoryChip.setBaseURI(newBaseUri);
        memoryChip.setURISuffix(newSuffix);

        // It should fail as empty string if no base URI provided
        assertEq(memoryChip.tokenURI(1), '', "The expected URL should be correct");
    }

    function testTotalChipsImplanted() public {
        // Should be public information// Should be public information
        vm.prank(user1);
        assertEq(memoryChip.totalChipsImplanted(), 0, "Total chips implanted should be zero");
    }

    function testTotalPeasantsMinted() public {
        // Should be public information
        vm.prank(user1);
        assertEq(memoryChip.totalPeasantsMinted(), 0, "Total peasants minted should be zero");
    }

    function testSupportsInterface() public {
        // Should be public information
        vm.prank(user1);
        assertEq(memoryChip.supportsInterface(0x80ac58cd), true, "Should support IERC721");
    }

    // =============================================================
    //                         GENERAL SETTERS
    // =============================================================

    function testSetMaxMintPerAddress() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.setMaxMintPerAddress(20);
        assertEq(memoryChip.maxMintPerAddress(), mcMintPerAddy, "Should have correctly set max mint per address");

        // Testing as owner
        vm.prank(owner);
        memoryChip.setMaxMintPerAddress(20);
        assertEq(memoryChip.maxMintPerAddress(), 20, "Should have correctly set max mint per address");
    }

    function testSetMintPrice() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.setMintPrice(0);
        assertEq(memoryChip.mintPrice(), mintPrice, "Should have correctly set mint price");

        // Testing as owner
        vm.prank(owner);
        memoryChip.setMintPrice(1 ether);
        assertEq(memoryChip.mintPrice(), 1 ether, "Should have correctly set mint price");
    }

    function testSetOpenBusiness() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.openBusiness();
        assertEq(memoryChip.businessOpen(), false, "By default business is closed.");

        // Testing as owner
        vm.prank(owner);
        memoryChip.openBusiness();
        assertEq(memoryChip.businessOpen(), true, "Business should now be open.");
    }

    function testOwner() public {
        vm.prank(user1);
        // vm.expectRevert();
        assertEq(memoryChip.owner(), owner, "Owner should be the owner");
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.transferOwnership(user1);

        vm.prank(owner);
        memoryChip.transferOwnership(user1);
        assertEq(memoryChip.owner(), user1, "User1 should be the owner");
    }

    function testWithdraw() public {
        vm.deal(address(memoryChip), 1 ether);

        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.withdraw();

        assertEq(address(memoryChip).balance, 1 ether, "Contract should still have one ether");
        
        // We need to change the ownership since the owner is the contract
        vm.prank(owner);
        memoryChip.transferOwnership(user1);

        // Testing as new owner
        vm.prank(user1);
        assertEq(user1.balance, 1 ether, "Owner should have one ether");
        memoryChip.withdraw();
        assertEq(address(memoryChip).balance, 0, "Contract should have no ether");
        assertEq(user1.balance, 2 ether, "Owner should have 2 ethers");
    }

    // =============================================================
    //                         SET CONTRACTS
    // =============================================================

    // Testing wether onlyOwner truly works
    function testSetGCContract() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.setGigaCityContract(address(gigaCity));

        // Testing as owner
        vm.prank(owner);
        memoryChip.setGigaCityContract(address(gigaCity));
        assertEq(memoryChip.gigaCityContract(), address(gigaCity), "Should have correct giga city contract address");
    }

    // =============================================================
    //                         SET MINT SLOTS
    // =============================================================

    function testToggleFilthyMint() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.toggleFilthyMint();
        assertEq(memoryChip.filthyMint(), false, "Filthy mint should be set to false");

        // Testing as owner
        vm.prank(owner);
        memoryChip.toggleFilthyMint();
        assertEq(memoryChip.filthyMint(), true, "Filthy mint should be set to true");
    }

    // Testing wether onlyOwner truly works
    function testToggleCorpoMint() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.toggleCorpoMint();
        assertEq(memoryChip.corpoMint(), false, "Corpo mint should be set to false");

        // Testing as owner
        vm.prank(owner);
        memoryChip.toggleCorpoMint();
        assertEq(memoryChip.corpoMint(), true, "Corpo mint should be set to true");
    }

    function testToggleBotMint() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.toggleBotMint();
        assertEq(memoryChip.botMint(), false, "Bot mint should be set to false");

        // Testing as owner
        vm.prank(owner);
        memoryChip.toggleBotMint();
        assertEq(memoryChip.botMint(), true, "Bot mint should be set to true");
    }
    
    function testToggleImplant() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.toggleImplant();
        assertEq(memoryChip.canImplant(), false, "Implant should be set to false");

        // Testing as owner
        vm.prank(owner);
        memoryChip.toggleImplant();
        assertEq(memoryChip.canImplant(), true, "Implant should be set to true");
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

contract WithDrawTest is MCSetup {

    function setUp() public override {
        super.setUp();
    }

        // Test a failing withdrawal:
    // When the owner is a contract that reverts on receiving Ether, the withdraw call should revert.
    function testWithdrawFailure() public {
        // Fund the MemoryChip contract with 1 ether.
        vm.deal(address(memoryChip), 1 ether);

        // Deploy a helper contract that refuses to accept Ether.
        RevertReceiver revertReceiver = new RevertReceiver();

        // Transfer ownership of MemoryChip to the revertReceiver.
        memoryChip.transferOwnership(address(revertReceiver));

        vm.prank(address(revertReceiver));
        vm.expectRevert(MemoryChip.WithdrawlFailed.selector);
        memoryChip.withdraw();
    }

}