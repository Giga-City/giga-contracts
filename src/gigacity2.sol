// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// =============================================================
//                           ROCKSTARS
// =============================================================

import "erc721a/extensions/ERC721AQueryable.sol";
import "solmate/utils/MerkleProofLib.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/access/Ownable.sol";

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
// Welcome to Giga City, a place that's seen it all. This
// city was once vibrant, but it fell victim to greed
// and insatiable need for control. Misguided policies
// and a relentless pursuit of wealth centralization sparked social
// unrest, changing the city forever. Now, Giga City stands as a
// testament to what can happen when the balance is lost.

// =============================================================
//                          ASSOCIATES
// =============================================================

abstract contract FilthyPeasantsContract {
    function ownerOf(uint tokenId) external virtual view returns(address);
}

// =============================================================
//                           Giga City
// =============================================================

contract GigaCity is
    ERC721AQueryable,
    ReentrancyGuard,
    Ownable {

    // █▒░ GENERAL ░▒█

    // What is the cap?
    uint256 public supplyCap;

    // How many NFTs we want ppl to mint?
    uint256 public maxMintPerAddress;

    // Same price for everyone.
    uint256 public mintPrice;

    // Where are our assets hosted?
    string private _baseTokenURI;
    
    // Once/if we will transition to IPFS this will come in handy
    string private _uriSuffix = '';

    // Users cant trade the NFT by default
    bool public businessOpen;

    // █▒░ PEASANTS ░▒█

    // Filthy fucking peasants.
    bool public filthyMint;

    // How many peasants have minted?
    uint256 private _filthyMintCounter;

    // Where the peasants at?
    address public filthyContract;

    // Mapping all the peasants that have minted.
    mapping(uint256 => bool) private _peasantsMinted;

    // █▒░ CORPO ░▒█

    // Corpos second
    bool public corpoMint;

    // Corpo merkle root
    bytes32 private _corpoRoot;

    // █▒░ BOT ░▒█

    // If it gets to its public last
    bool public botMint;

    // =============================================================
    //                            ERRORS
    // =============================================================

    error BusinessClosed();
    error WithdrawlFailed();
    error SupplyExceeded();
    error AddressQuantityExceeded();
    error NoFilthyMintYet();
    error NoCorpoMintYet();
    error NoBotMintYet();
    error CantMintThisFilthy();
    error CantMintCorpo();
    error PeasantAlreadyMinted();
    error CypherPunkDoesNotExist();
    error CantIncreaseSupply();
    error CantDecreaseSupply();
    error IncorrectETHSent();

    event URISuffixUpdated(string previous, string current);
    event BaseURIChanged(string previous, string current);
    event SupplyCapChanged(uint256 previous, uint256 current);

 
    // =============================================================
    //                            CONSTRUCTOR
    // =============================================================

    constructor(
        address filthyContract_,
        uint256 supplyCap_,
        uint256 maxMintPerAddress_,
        address owner_
    ) ERC721A(
        "Memory Chip",
        "MC"
    ) Ownable(owner_) {
        filthyContract = filthyContract_;
        supplyCap = supplyCap_;
        maxMintPerAddress = maxMintPerAddress_;
    }

    // =============================================================
    //                          MINT HELPERS
    // =============================================================

    function _isWithinSupply(uint256 quantity_) private view {
        // Are we exceeding our supply cap? The supply of filthy peasants is capped at 333.
        if (supplyCap < _totalMinted() + quantity_ - _filthyMintCounter) revert SupplyExceeded();
    }

    function _isWithinWalletLimit(uint256 quantity_) private view {
        // Did the user already exceed the allowed limit?
        if (_numberMinted(_msgSenderERC721A()) + quantity_ > maxMintPerAddress) revert AddressQuantityExceeded();
    }

    function _hasEnoughCash(uint256 quantity_) private view {
        // Are you sending enough cash for mint?
        if (msg.value != mintPrice * quantity_) revert IncorrectETHSent();
    }

    // =============================================================
    //                             TREASURY
    // =============================================================

    // How am I going to mint the treasury?
    function mintTreasury(address address_, uint256 quantity_) external onlyOwner {
        // Are we exceeding a supply cap?
        _isWithinSupply(quantity_);
        // We mint for free
        _mint(address_, quantity_);
    }

    // =============================================================
    //                           MINT FILTHY
    // =============================================================

    // How are peasants going to mint? Mfers mint filthy!
    function mintFilthy(uint256 peasantId_) external {
        // Is filthy mint on?
        if (!filthyMint) revert NoFilthyMintYet();
        // Are we exceeding a supply cap?
        // I don't think we need to check. There is only 333 peasants
        // and the supply cannot be changed. In fact checking the total
        // supply would make the code unnecessarily complicated since
        // peasants need reserved capacity to mint.
        // _isWithinSupply(_quantity);
        // Are you filthy?
        if (FilthyPeasantsContract(filthyContract).ownerOf(peasantId_) != msg.sender) revert CantMintThisFilthy();
        // Has the peasant been redeemed?
        if (_peasantsMinted[peasantId_] == true) revert PeasantAlreadyMinted();
        // If not, it is redeemed now
        _peasantsMinted[peasantId_] = true;
        // We need to know how many filthys have minted
        _filthyMintCounter += 1;
        // And we finally mint.
        _mint(msg.sender, 2);
    }

    // =============================================================
    //                         MINT PRIVILEGED
    // =============================================================

    // How is waitlist going to mint?
    function mintCorpo(bytes32[] calldata proof_, uint256 quantity_) external payable {
        // Is privileged mint on?
        if (!corpoMint) revert NoCorpoMintYet();
        // Are we exceeding a supply cap?
        _isWithinSupply(quantity_);
        // Is the address overallocating?
        _isWithinWalletLimit(quantity_);
        // Are you actualy privileged?
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        if (!MerkleProofLib.verify(proof_, _corpoRoot, leaf)) revert CantMintCorpo();
        // Do you have enough cash?
        _hasEnoughCash(quantity_);
        // We continue minting. 
        _mint(msg.sender, quantity_);
    }

    // =============================================================
    //                         MINT PUBLIC
    // =============================================================

    function mintBot(uint256 quantity_) external payable {
        // Is the public mint on?
        if (!botMint) revert NoBotMintYet();
        // Are we exceeding a supply cap?
        _isWithinSupply(quantity_);
        // Is the address overallocating?
        _isWithinWalletLimit(quantity_);
        // Do you have enough cash?
        _hasEnoughCash(quantity_);
        // If you are good, you are good.
        _mint(msg.sender, quantity_);
    }

    // =============================================================
    //                              INFO
    // =============================================================

    function peasantMinted(uint256 peasantId_) external view returns (bool) {
        return _peasantsMinted[peasantId_] == true;
    }

    function totalPeasantsMinted() external view returns (uint256) {
        return _filthyMintCounter;
    }

    // =============================================================
    //                              METADATA
    // =============================================================

    function _startTokenId() internal view override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId_) public view override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(tokenId_)) revert CypherPunkDoesNotExist();

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _toString(tokenId_), _uriSuffix))
            : '';
    }

    // =============================================================
    //                              ADMIN
    // =============================================================

    function setBaseURI(string calldata baseURI_) external onlyOwner {
        string memory prev = _baseTokenURI;
        _baseTokenURI = baseURI_;
        emit BaseURIChanged(prev, baseURI_);
    }

    function setURISuffix(string calldata uriSuffix_) external onlyOwner {
        string memory prev = _uriSuffix;
        _uriSuffix = uriSuffix_;
        emit URISuffixUpdated(prev, uriSuffix_);
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

    function setSupplyCap(uint256 supplyCap_) external onlyOwner {
        if (supplyCap_ > supplyCap) revert CantIncreaseSupply();
        if (supplyCap_ < _totalMinted()) revert CantDecreaseSupply();
        emit SupplyCapChanged(supplyCap, supplyCap_);
        supplyCap = supplyCap_;
    }

    function toggleCorpoMint() public onlyOwner {
        corpoMint = !corpoMint;
    }

    function toggleBotMint() external onlyOwner {
        botMint = !botMint;
    }

    function toggleFilthyMint() public onlyOwner {
        filthyMint = !filthyMint;
    }

    function openBusiness() external onlyOwner {
        businessOpen = true;
    }

    // =============================================================
    //                           OWNABLE
    // =============================================================

    /**
     * Override needed due to fonflict. Super.owner() returns
     * direct parent, which in this case is Ownable contract.
     */
    function owner() public view virtual override(Ownable) returns (address) {
        return super.owner();
    }

    // =============================================================
    //                           WITHDRAW
    // =============================================================

    function withdraw() external onlyOwner nonReentrant() {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) revert WithdrawlFailed();
    }

    // =============================================================
    //                           INTERFACE
    // =============================================================

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (IERC721A, ERC721A)
        returns (bool)
    {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        return ERC721A.supportsInterface(interfaceId);
    }

    // Override the transfer functions to check trading status
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override(ERC721A, IERC721A) {
        if (!businessOpen) revert BusinessClosed();
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override(ERC721A, IERC721A) {
        if (!businessOpen) revert BusinessClosed();
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable virtual override(ERC721A, IERC721A) {
        if (!businessOpen) revert BusinessClosed();
        super.safeTransferFrom(from, to, tokenId, _data);
    }
}