// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_mcSetup.sol";

contract GCSetup is MCSetup {

  function setUp() public virtual override {
      super.setUp();

      // ****** BASICS ****** //
      
      // Metadata
      gigaCity.setBaseURI(baseURI);
      gigaCity.setURISuffix(URISuffix);
  }
}