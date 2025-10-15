// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// =============================================================
//                           ROCKSTARS
// =============================================================

// Thank you for all the open source work.

import "solmate/utils/MerkleProofLib.sol";
import "solmate/utils/LibString.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "solady/utils/SafeTransferLib.sol";
import "@limitbreak/creator-token-standards/src/access/OwnableBasic.sol";
import "@limitbreak/creator-token-standards/src/erc721c/ERC721AC.sol";
import "@limitbreak/creator-token-standards/src/programmable-royalties/BasicRoyalties.sol";

// =============================================================
//
//   ▄████  ██▓  ▄████  ▄▄▄       ▄████▄   ██▓▄▄▄█████▓▓██   ██▓
//  ██▒ ▀█▒▓██▒ ██▒ ▀█▒▒████▄    ▒██▀ ▀█  ▓██▒▓  ██▒ ▓▒ ▒██  ██▒
// ▒██░▄▄▄░▒██▒▒██░▄▄▄░▒██  ▀█▄  ▒▓█    ▄ ▒██▒▒ ▓██░ ▒░  ▒██ ██░
// ░▓█  ██▓░██░░▓█  ██▓░██▄▄▄▄██ ▒▓▓▄ ▄██▒░██░░ ▓██▓ ░   ░ ▐██▓░
// ░▒▓███▀▒░██░░▒▓███▀▒ ▓█   ▓██▒▒ ▓███▀ ░░██░  ▒██▒ ░   ░ ██▒▓░
//  ░▒   ▒ ░▓   ░▒   ▒  ▒▒   ▓▒█░░ ░▒ ▒  ░░▓    ▒ ░░      ██▒▒▒ 
//   ░   ░  ▒ ░  ░   ░   ▒   ▒▒ ░  ░  ▒    ▒ ░    ░     ▓██ ░▒░ 
// ░ ░   ░  ▒ ░░ ░   ░   ░   ▒   ░         ▒ ░  ░       ▒ ▒ ░░  
//       ░  ░        ░       ░  ░░ ░       ░            ░ ░     
//                              ░                      ░ ░     
//
// Welcome to GC, a place that's seen it all. This
// city was once vibrant, but it fell victim to greed
// and insatiable need for control. Misguided policies
// and a relentless pursuit of wealth centralization sparked social
// unrest, changing the city forever. Now, Giga City stands as a
// testament to what can happen when the balance is lost.
//
// =============================================================


contract GigaCity is OwnableBasic, ERC721AC, BasicRoyalties, ReentrancyGuard {

    // █▒░ PUBLIC ░▒█

    uint256 public supplyCap = 10000;
    uint256 public maxMintPerAddress;
    uint256 public mintPrice;

    // █▒░ DATA ░▒█

    string private _baseTokenURI;
    string private _uriSuffix;
    bytes32 private _corpoRoot;

    // █▒░ CONTROLS ░▒█

    bool public corpoMint;
    bool public botMint;

    // █▒░ WHO KNOWS ░▒█
    
    bool public countdownInitiated;

    // =============================================================
    //                            EVENTS
    // =============================================================

    event BaseURIChanged(string newBaseURI);
    event URISuffixChanged(string newSuffix);
    event CorpoRootChanged();
    event MaxMintPerAddressChanged(uint256 newMaxMintPerAddress_);
    event MintPriceChanged(uint256 newMintPrice_);
    event CorpoMintChanged(bool _newState);
    event BotMintChanged(bool _newState);
    event CountdownInitiated();

    // =============================================================
    //                            ERRORS
    // =============================================================

    error CorpoMintClosed();
    error BotMintClosed();
    error SupplyExceeded();
    error NoCashForMint();
    error AddressQuantityExceeded();
    error CantMintCorpo();
    error TokenDoesNotExist();
    error InvalidAddress();

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    constructor(address royaltyReceiver_, address owner_)
        ERC721AC("Giga City", "GC")
        BasicRoyalties(royaltyReceiver_, 333)
        Ownable(owner_) {

        maxMintPerAddress = 10;
        mintPrice = 0;

        corpoMint = false;
        botMint = false;

        _baseTokenURI = '';
        _uriSuffix = '';

        countdownInitiated = false;
    }

    // =============================================================
    //                            HELPERS
    // =============================================================

    function _isWithinSupply(uint256 quantity_) private view {
        // Are we exceeding our supply cap?
        if (supplyCap < _totalMinted() + quantity_) revert SupplyExceeded();
    }

    function _isWithinWalletLimit(uint256 quantity_) private view {
        // Did the user already exceed the allowed limit?
        if (_numberMinted(msg.sender) + quantity_ > maxMintPerAddress) revert AddressQuantityExceeded();
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
        // No null addresses
        if (address_ == address(0)) revert InvalidAddress();
        // We mint for free
        _mint(address_, quantity_);
    }

    function mintCorpo(bytes32[] calldata proof_, uint256 quantity_) external payable {
        // Is corpo mint on?
        if (!corpoMint) revert CorpoMintClosed();
        // Are we exceeding a supply cap?
        _isWithinSupply(quantity_);
        // Is the address overallocating?
        _isWithinWalletLimit(quantity_);
        // Are you actualy corpo?
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        if (!MerkleProofLib.verify(proof_, _corpoRoot, leaf)) revert CantMintCorpo();
        // Do you have enough cash?
        _hasEnoughCash(quantity_);
        // We continue minting. 
        _safeMint(msg.sender, quantity_);
        // Refund
        uint256 cost = mintPrice * quantity_;
        if (msg.value > cost) {
            SafeTransferLib.safeTransferETH(msg.sender, msg.value - cost);
        }
    }

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
        _safeMint(msg.sender, quantity_);
        // Refund
        uint256 cost = mintPrice * quantity_;
        if (msg.value > cost) {
            SafeTransferLib.safeTransferETH(msg.sender, msg.value - cost);
        }
    }

    // =============================================================
    //                           METADATA
    // =============================================================

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        if (!_exists(tokenId_)) revert TokenDoesNotExist();

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
        emit BaseURIChanged(baseURI_);
    }

    function setURISuffix(string calldata uriSuffix_) external onlyOwner {
        _uriSuffix = uriSuffix_;
        emit URISuffixChanged(uriSuffix_);
    }

    function setCorpoRoot(bytes32 newRoot_) external onlyOwner {
        _corpoRoot = newRoot_;
        emit CorpoRootChanged();
    }

    function setMaxMintPerAddress(uint256 maxMintPerAddress_) external onlyOwner {
        maxMintPerAddress = maxMintPerAddress_;
        emit MaxMintPerAddressChanged(maxMintPerAddress_);
    }

    function setMintPrice(uint256 mintPrice_) external onlyOwner {
        mintPrice = mintPrice_;
        emit MintPriceChanged(mintPrice_);
    }

    function toggleCorpoMint() external onlyOwner {
        corpoMint = !corpoMint;
        emit CorpoMintChanged(corpoMint);
    }

    function toggleBotMint() external onlyOwner {
        botMint = !botMint;
        emit BotMintChanged(botMint);
    }
    
    function initiateCountdown() external onlyOwner {
        countdownInitiated = true;
        emit CountdownInitiated();
    }

    function withdraw() external onlyOwner nonReentrant {
        SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
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