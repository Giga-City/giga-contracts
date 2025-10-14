// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@limitbreak/creator-token-standards/src/access/OwnableBasic.sol";
import "@limitbreak/creator-token-standards/src/erc721c/ERC721AC.sol";
import "@limitbreak/creator-token-standards/src/programmable-royalties/BasicRoyalties.sol";

// =============================================================
//                            GigaCity
// =============================================================

contract GigaCity is OwnableBasic, ERC721AC, BasicRoyalties {

    // █▒░ PUBLIC ░▒█

    uint256 public supplyCap;
    uint256 public maxMintPerAddress;
    uint256 public mintPrice;

    // █▒░ PRIVATE ░▒█

    string private _baseTokenURI;
    string private _uriSuffix = '';

    // █▒░ CONTROLS ░▒█

    bool public corpoMint;
    bool public botMint;

    // =============================================================
    //                            ERRORS
    // =============================================================

    error CorpoMintClosed();
    error BotMintClosed();
    error SupplyExceeded();
    error AddressQuantityExceeded();

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    constructor(address royaltyReceiver_)
        ERC721AC("Giga City", "GC")
        BasicRoyalties(royaltyReceiver_, 333) {
    }

    // =============================================================
    //                           HELPERS
    // =============================================================

    function _isWithinSupply(uint256 quantity_) private view {
        // Are we exceeding our supply cap?
        if (supplyCap < _totalMinted() + quantity_) revert SupplyExceeded();
    }

    function _isWithinWalletLimit(uint256 quantity_) private view {
        // Did the user already exceed the allowed limit?
        if (_numberMinted(_msgSenderERC721A()) + quantity_ > maxMintPerAddress) revert AddressQuantityExceeded();
    }

    function _hasEnoughCash(uint256 quantity_) private view {
        // Are you sending enough cash for mint?
        if (msg.value < mintPrice * quantity_) revert NoCashForMint();
    }

    // =============================================================
    //                             MINT
    // =============================================================

    // How am I going to mint the treasury?
    function mintTreasury(address address_, uint256 quantity_) external onlyOwner {
        // Are we exceeding a supply cap?
        _isWithinSupply(quantity_);
        // We mint for free
        _mint(address_, quantity_);
    }

    // function mint(address to, uint256 quantity) external {
    //     // Are we exceeding our supply cap?
    //     if (supplyCap < _totalMinted()) revert SupplyExceeded();
    //     // Did the user already exceed the allowed limit?
    //     if (_numberMinted(_msgSenderERC721A()) + quantity_ > maxMintPerAddress) revert AddressQuantityExceeded();
    //     // Are you sending enough cash for mint?
    //     if (msg.value < mintPrice * quantity_) revert NoCashForMint();

    //     _mint(to, quantity);
    // }

    function mintBot(uint256 quantity_) external payable {
        // Is the public mint on?
        if (!botMint) revert BotMintClosed();
        // Are we exceeding a supply cap?
        _isWithinSupply(quantity_);
        // Is the address overallocating?
        _isWithinWalletLimit(quantity_);
        // Do you have enough cash?
        _hasEnoughCash(quantity_);
        // If you are good, you are good.
        _mint(_msgSenderERC721A(), quantity_);
    }




    // function safeMint(address to, uint256 quantity) external {
    //     _safeMint(to, quantity);
    // }

    // function burn(uint256 tokenId) external {
    //     _burn(tokenId);
    // }

    // =============================================================
    //                           METADATA
    // =============================================================

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId_) public view override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(tokenId_)) revert ChipDoesNotExist();

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, LibString.toString(tokenId_), _uriSuffix))
            : '';
    }

    // =============================================================
    //                              ADMIN
    // =============================================================

    function setBaseURI(string calldata baseURI_) external onlyOwner {
        _baseTokenURI = baseURI_;
    }

    function setURISuffix(string calldata uriSuffix_) external onlyOwner {
        _uriSuffix = uriSuffix_;
    }

    function setCorpoRoot(bytes32 newRoot_) external onlyOwner {
        _corpoRoot = newRoot_;
    }

    function setMaxMintPerAddress(uint256 maxMintPerAddress_) external onlyOwner {
        maxMintPerAddress = maxMintPerAddress_;
    }

    function setMintPrice(uint256 mintPrice_) external onlyOwner {
        mintPrice = mintPrice_;
    }

    function toggleCorpoMint() public onlyOwner {
        corpoMint = !corpoMint;
    }

    function toggleBotMint() external onlyOwner {
        botMint = !botMint;
    }

    // =============================================================
    //                          ROYALTIES
    // =============================================================

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public {
        _requireCallerIsContractOwner();
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) public {
        _requireCallerIsContractOwner();
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    // =============================================================
    //                           INTERFACE
    // =============================================================

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721AC, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}