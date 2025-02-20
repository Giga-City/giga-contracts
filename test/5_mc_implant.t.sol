
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_mcSetup.sol";

contract MemoryChipTest is MCSetup {
    function setUp() public override {
        super.setUp();

        memoryChip.toggleBotMint();
        memoryChip.toggleImplant();

        vm.prank(user1);
        memoryChip.mintBot{value: 0.02 ether}(2);

        vm.prank(user2);
        memoryChip.mintBot{value: 0.02 ether}(2);
    }

    // =============================================================
    //                        TEST IMPLANT
    // =============================================================

    function testCantImplantWhenNoImplant() public {
        memoryChip.toggleImplant();
        vm.expectRevert(MemoryChip.CantImplantNow.selector);
        memoryChip.implant(1);
    }

    function testCantImplantWhenNotYours() public {
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.implant(3);
    }

    function testImplant() public {
        // Should be able to implant even if business is closed
        assertEq(memoryChip.businessOpen(), false, "Business should be closed");

        vm.prank(user1);
        memoryChip.implant(1);
        assertEq(memoryChip.chipsImplanted(user1), 1, "User implanted 1 MC");
        assertEq(memoryChip.totalChipsImplanted(), 1, "Total chips implanted: 1 MC");

        memoryChip.openBusiness();
        assertEq(memoryChip.businessOpen(), true, "Business should be closed");

        vm.prank(user1);
        memoryChip.implant(2);
        assertEq(memoryChip.chipsImplanted(user1), 2, "User implanted 2 MCs");
        assertEq(memoryChip.totalChipsImplanted(), 2, "Total chips implanted: 2 MC");
    }
}