// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_deploySetup.sol";

contract DeployTest is DeploySetup {
    // If needed, override setUp to add additional initialization,
    // but don't forget to call super.setUp() for the base logic.
    function setUp() public override {
        super.setUp();
        // Additional setup if necessary.
    }

    function testMemoryChipValues() public view {
        assertEq(memoryChip.name(), 'Memory Chip', "Wrong Memory chip deploy name");
        assertEq(memoryChip.symbol(), 'MC', "Wrong Memory chip symbol");
        assertEq(memoryChip.supplyCap(), mcSupplyCap, "Wrong supply cap");
        assertEq(memoryChip.maxMintPerAddress(), 1, "Wron max mint per address");
        assertEq(memoryChip.owner(), owner, "Wrong mc contract owner");
    }

    function testGigaCityValues() public view {
        assertEq(gigaCity.name(), 'Giga City', "Wrong Giga City deploy name");
        assertEq(gigaCity.symbol(), 'GC', "Wrong Giga City symbol");
        assertEq(gigaCity.memoryChipContract(), address(memoryChip), "Wrong Memory chip contract");
        assertEq(gigaCity.initiateCountdown(), false, "Wrong countdown state");
    }
}