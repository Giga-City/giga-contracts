// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./_mcSetup.sol";

contract MemoryChipTest is MCSetup {

    function setUp() public override {
        super.setUp();
    }

    function testMintTreasury() public {
        vm.prank(user1);
        vm.expectRevert();
        memoryChip.mintTreasury(user1, 2);

        vm.prank(owner);
        memoryChip.mintTreasury(owner, 2);
    }

}