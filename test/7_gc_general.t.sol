// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_gcSetup.sol";

// Mock contract representing an unauthorized contract
contract UnauthorizedImplant {
    address public MCContract;

    constructor(address _yourContract) {
        MCContract = _yourContract;
    }

    function callImplant(address to) public {
        GigaCityContract factory = GigaCityContract(MCContract);
        factory.implant(to);
    }
}

contract GigaCityChipTest is GCSetup {
    UnauthorizedImplant public unauthorisedContract;

    function setUp() public override {
        super.setUp();

        memoryChip.mintTreasury(address(user1), 3);
        memoryChip.toggleImplant();

        vm.prank(user1);
        memoryChip.implant(1);

        unauthorisedContract = new UnauthorizedImplant(address(memoryChip));
    }

    // =============================================================
    //                         INFO GETTERS
    // =============================================================

    function testRevertImplant() public {
        vm.prank(user1);
        memoryChip.implant(2);

        vm.prank(user1);
        vm.expectRevert();
        gigaCity.implant(user1);
    }

    function testImplantFromDifferentCOntract() public {
        vm.prank(user1);
        vm.expectRevert();
        unauthorisedContract.callImplant(address(user1));
    }

    function testNoBaseURI() public {
        vm.expectRevert();
        gigaCity.tokenURI(10);
      
        assertEq(gigaCity.tokenURI(1), string.concat(baseURI,'1', URISuffix), "The expected URL should be correct");

        string memory newBaseUri = 'http://yee.co/';
        string memory newSuffix = '';

        gigaCity.setBaseURI(newBaseUri);
        gigaCity.setURISuffix(newSuffix);

        // It should fail as empty string if no base URI provided
        assertEq(gigaCity.tokenURI(1), string.concat(newBaseUri,'1', newSuffix), "The expected URL should be correct");
    }

    function testSupportsInterface() public {
        // Should be public information
        vm.prank(user1);
        assertEq(gigaCity.supportsInterface(0x80ac58cd), true, "Should support IERC721");
    }

    // =============================================================
    //                         GENERAL SETTERS
    // =============================================================


    function testSetOpenBusiness() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.initiateCountdown();
        assertEq(gigaCity.countdownInitiated(), false, "By default countdown is not running.");

        // Testing as owner
        vm.prank(owner);
        gigaCity.initiateCountdown();
        assertEq(gigaCity.countdownInitiated(), true, "Countdown should now be running.");
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

contract WithDrawTest is GCSetup {

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
        gigaCity.transferOwnership(address(revertReceiver));

        vm.prank(address(revertReceiver));
        vm.expectRevert(GigaCity.WithdrawlFailed.selector);
        gigaCity.withdraw();
    }
}