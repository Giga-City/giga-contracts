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

    function testGigaCityValues() public view {
        assertEq(gigaCity.name(), 'Giga City', "Wrong Giga City deploy name");
        assertEq(gigaCity.symbol(), 'GC', "Wrong Giga City symbol");
        assertEq(gigaCity.countdownInitiated(), false, "Wrong countdown state");
        assertEq(gigaCity.owner(), owner, "Wrong GC contract owner");
    }
}