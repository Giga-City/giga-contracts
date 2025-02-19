// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_mcSetup.sol";

contract MemoryChipTest is MCSetup {

    function setUp() public override {
        super.setUp();
    }

    // Testing wether onlyOwner truly works
    function testMintTreasury() public {
        // This should not pass as user1 is not owner
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.mintTreasury(user1, 2);

        // Testing as owner
        vm.prank(owner);
        memoryChip.mintTreasury(owner, 2);
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
}