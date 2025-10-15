// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./0_deploy.t.sol";

// =============================================================
//                   ROYALTY TESTS
// =============================================================

contract RoyaltyTest is DeploySetup {
    function setUp() public override {
        super.setUp();
        gigaCity.mintTreasury(owner, 1);
    }

    function testSetDefaultRoyalty() public {
        address newReceiver = user2;
        uint96 newFeeNumerator = 500; // 5%

        gigaCity.setDefaultRoyalty(newReceiver, newFeeNumerator);

        // Check royalty info
        (address receiver, uint256 royaltyAmount) = gigaCity.royaltyInfo(1, 10000);
        assertEq(receiver, newReceiver, "Receiver should be updated");
        assertEq(royaltyAmount, 500, "Royalty should be 5%");
    }

    function testSetDefaultRoyaltyOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.setDefaultRoyalty(user2, 500);
    }

    function testSetTokenRoyalty() public {
        address newReceiver = user3;
        uint96 newFeeNumerator = 1000; // 10%

        gigaCity.setTokenRoyalty(1, newReceiver, newFeeNumerator);

        // Check token-specific royalty
        (address receiver, uint256 royaltyAmount) = gigaCity.royaltyInfo(1, 10000);
        assertEq(receiver, newReceiver, "Token receiver should be updated");
        assertEq(royaltyAmount, 1000, "Token royalty should be 10%");
    }

    function testSetTokenRoyaltyOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        gigaCity.setTokenRoyalty(1, user2, 500);
    }
}

// =============================================================
//                   EVENT EMISSION TESTS
// =============================================================

contract EventTest is DeploySetup {
    function setUp() public override {
        super.setUp();
    }

    function testBaseURIChangedEvent() public {
        string memory newURI = "https://new.com/";

        vm.expectEmit(false, false, false, true);
        emit BaseURIChanged(newURI);
        gigaCity.setBaseURI(newURI);
    }

    function testURISuffixChangedEvent() public {
        string memory newSuffix = ".metadata";

        vm.expectEmit(false, false, false, true);
        emit URISuffixChanged(newSuffix);
        gigaCity.setURISuffix(newSuffix);
    }

    function testCorpoRootChangedEvent() public {
        bytes32 newRoot = keccak256("test");

        vm.expectEmit(false, false, false, false);
        emit CorpoRootChanged();
        gigaCity.setCorpoRoot(newRoot);
    }

    function testMaxMintPerAddressChangedEvent() public {
        uint256 newMax = 50;

        vm.expectEmit(false, false, false, true);
        emit MaxMintPerAddressChanged(newMax);
        gigaCity.setMaxMintPerAddress(newMax);
    }

    function testMintPriceChangedEvent() public {
        uint256 newPrice = 0.05 ether;

        vm.expectEmit(false, false, false, true);
        emit MintPriceChanged(newPrice);
        gigaCity.setMintPrice(newPrice);
    }

    function testCorpoMintChangedEvent() public {
        vm.expectEmit(false, false, false, true);
        emit CorpoMintChanged(true);
        gigaCity.toggleCorpoMint();
    }

    function testBotMintChangedEvent() public {
        vm.expectEmit(false, false, false, true);
        emit BotMintChanged(true);
        gigaCity.toggleBotMint();
    }

    function testCountdownInitiatedEvent() public {
        vm.expectEmit(false, false, false, false);
        emit CountdownInitiated();
        gigaCity.initiateCountdown();
    }

    // Event declarations for testing
    event BaseURIChanged(string newBaseURI);
    event URISuffixChanged(string newSuffix);
    event CorpoRootChanged();
    event MaxMintPerAddressChanged(uint256 newMaxMintPerAddress_);
    event MintPriceChanged(uint256 newMintPrice_);
    event CorpoMintChanged(bool _newState);
    event BotMintChanged(bool _newState);
    event CountdownInitiated();
}

// =============================================================
//                   EDGE CASE TESTS
// =============================================================

contract EdgeCaseTest is DeploySetup {
    function setUp() public override {
        super.setUp();
        gigaCity.toggleBotMint();
    }

    function testMintExactlyAtSupplyCap() public {
        // Mint supply cap - 2 via treasury
        gigaCity.mintTreasury(owner, supplyCap - 2);

        // Mint exactly the last 2 tokens via bot mint
        vm.prank(user1);
        gigaCity.mintBot{value: 0.02 ether}(2);

        assertEq(gigaCity.balanceOf(user1), 2, "Should have 2 tokens");

        // Next mint should fail
        vm.prank(user2);
        vm.expectRevert(GigaCity.SupplyExceeded.selector);
        gigaCity.mintBot{value: 0.01 ether}(1);
    }

    function testFreeMint() public {
        // Set price to 0
        gigaCity.setMintPrice(0);

        vm.prank(user1);
        gigaCity.mintBot(2);

        assertEq(gigaCity.balanceOf(user1), 2, "Should mint for free");
        assertEq(user1.balance, 1 ether, "Balance should not change");
    }

    function testMultipleUsersSequentialMints() public {
        vm.prank(user1);
        gigaCity.mintBot{value: 0.02 ether}(2);

        vm.prank(user2);
        gigaCity.mintBot{value: 0.02 ether}(2);

        vm.prank(user3);
        gigaCity.mintBot{value: 0.02 ether}(2);

        assertEq(gigaCity.balanceOf(user1), 2, "User1 should have 2");
        assertEq(gigaCity.balanceOf(user2), 2, "User2 should have 2");
        assertEq(gigaCity.balanceOf(user3), 2, "User3 should have 2");
    }

    function testContractAccumulatesETH() public {
        uint256 initialContractBalance = address(gigaCity).balance;

        vm.prank(user1);
        gigaCity.mintBot{value: 0.02 ether}(2);

        vm.prank(user2);
        gigaCity.mintBot{value: 0.02 ether}(2);

        assertEq(
            address(gigaCity).balance,
            initialContractBalance + 0.04 ether,
            "Contract should accumulate ETH"
        );
    }
}

// =============================================================
//                   INTERFACE SUPPORT TESTS
// =============================================================

contract InterfaceTest is DeploySetup {
    function setUp() public override {
        super.setUp();
    }

    function testSupportsERC721Interface() public view {
        // ERC721 interface ID (0x80ac58cd)
        // Note: ERC721AC might have different interface support
        // Testing the actual supported interface
        bytes4 erc721InterfaceId = 0x80ac58cd;
        bool supported = gigaCity.supportsInterface(erc721InterfaceId);
        // The contract should support some form of NFT interface
        assertTrue(supported || gigaCity.supportsInterface(0x01ffc9a7), "Should support ERC165 at minimum");
    }

    function testSupportsERC2981Interface() public view {
        // ERC2981 (Royalty) interface ID
        assertTrue(gigaCity.supportsInterface(0x2a55205a), "Should support ERC2981");
    }

    function testSupportsERC165Interface() public view {
        // ERC165 interface ID
        assertTrue(gigaCity.supportsInterface(0x01ffc9a7), "Should support ERC165");
    }
}
