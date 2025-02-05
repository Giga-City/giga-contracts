// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/memorychip.sol";
import "erc721a/IERC721A.sol";



contract MemoryChipTest is Test {
    MemoryChip public chip;

    function setUp() public {
        chip = new MemoryChip(10000, 10);
    }

    function testInitialization() public view {
        // Verify initial state
        assertEq(chip.owner(), address(this));
    }

    // function testMint() public {
    //     uint256 mintPrice = chip.mintPrice();
        
    //     // Mint with correct price
    //     chip.mint{value: mintPrice}();
        
    //     assertEq(chip.balanceOf(address(this)), 1);
    //     assertEq(chip.ownerOf(0), address(this));
    // }

    // function testFailMintInsufficientPayment() public {
    //     uint256 mintPrice = chip.MINT_PRICE();
        
    //     // Try to mint with less than required price
    //     chip.mint{value: mintPrice - 1}();
    // }

    // function testFailMintSupplyExceeded() public {
    //     uint256 mintPrice = chip.MINT_PRICE();
    //     uint256 maxSupply = chip.MAX_SUPPLY();

    //     // Mint up to max supply
    //     for(uint256 i = 0; i < maxSupply; i++) {
    //         chip.mint{value: mintPrice}();
    //     }

    //     // This should fail as supply is exceeded
    //     chip.mint{value: mintPrice}();
    // }

    // function testMintEmitsEvent() public {
    //     uint256 mintPrice = chip.MINT_PRICE();
    //     vm.expectEmit(true, true, true, true);
    //     emit IERC721A.Transfer(address(0), address(this), 0);
        
    //     chip.mint{value: mintPrice}();
    // }
}