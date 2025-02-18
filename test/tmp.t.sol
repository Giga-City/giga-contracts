// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TestSetup.sol";

contract MyContractTest is TestSetup {
    // If needed, override setUp to add additional initialization,
    // but don't forget to call super.setUp() for the base logic.
    function setUp() public override {
        super.setUp();
        // Additional setup if necessary.
    }

    function testInitialValue() public {
        assertEq(memoryChip.canImplant(), false, "Init implant should be off");
    }

}