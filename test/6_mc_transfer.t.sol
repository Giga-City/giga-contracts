
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_mcSetup.sol";

contract MemoryChipTest is MCSetup {
    function setUp() public override {
        super.setUp();

        memoryChip.toggleBotMint();

        vm.prank(user1);
        memoryChip.mintBot{value: 0.02 ether}(2);

        vm.prank(user2);
        memoryChip.mintBot{value: 0.02 ether}(2);
    }

    function getRandomBytes() public view returns (bytes memory) {
        // Generate a pseudo-random bytes32 hash using on-chain data.
        bytes32 randomHash = keccak256(abi.encodePacked(block.timestamp,msg.sender));
        // Convert the hash to a bytes variable.
        return abi.encodePacked(randomHash);
    }

    // =============================================================
    //                        TEST IMPLANT
    // =============================================================

    function testCantSendWhenBusinessClosed() public {
        vm.expectRevert(MemoryChip.BusinessClosed.selector);
        memoryChip.transferFrom(user1, user2, 1);
        vm.expectRevert(MemoryChip.BusinessClosed.selector);
        memoryChip.safeTransferFrom(user1, user2, 1);

        bytes memory tmpBytes = getRandomBytes();

        vm.expectRevert(MemoryChip.BusinessClosed.selector);
        memoryChip.safeTransferFrom(user1, user2, 1, tmpBytes);
    }

      function testCanSendWhenBusinessOpen() public {
        memoryChip.openBusiness();

        assertEq(memoryChip.ownerOf(1), user1, "User 1 should be the owner of the NFT");

        vm.prank(user1);
        memoryChip.transferFrom(user1, user2, 1);

        vm.prank(user2);
        memoryChip.safeTransferFrom(user2, user1, 1);

        bytes memory tmpBytes = getRandomBytes();
        vm.prank(user1);
        memoryChip.safeTransferFrom(user1, user2, 1, tmpBytes);
    }
}