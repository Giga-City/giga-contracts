// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// =============================================================
//                           ROCKSTARS
// =============================================================

import "erc721a/extensions/ERC721AQueryable.sol";
import "solmate/utils/MerkleProofLib.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "solmate/utils/LibString.sol";
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
// Yo! Welcome to Giga City, a place that's seen it all. This
// city was once vibrant, but it fell victim to greed
// and insatiable need for control. Misguided policies
// and a relentless pursuit of wealth centralization sparked social
// unrest, changing the city forever. Now, Giga City stands as a
// testament to what can happen when the balance is lost.

// ... mfer. Listen. I really appreciate you checking out the project.
// Not sure how you got here. But I have been working on GC almost every
// night for a while now. I've poured every last drip of blood and sweat
// into this thing so I hope it fucking shows. No matter if you own this
// GC or not, no matter if you just flip it and move on or hold. Thank
// you for checking it out.
//
// But I'll do everything that I can to get you on this ship with me!

// =============================================================
//                          ASSOCIATES
// =============================================================

abstract contract GigaCityContract {
    function implant(address to) external virtual;
}

abstract contract FilthyPeasantsContract {
    function ownerOf(uint tokenId) external virtual view returns(address);
}

// =============================================================
//                           Memory Chip
// =============================================================

contract MemoryChip is
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

    // Let's get on with it
    bool public canImplant;

    // Where is GC at?
    address public gigaCityContract;

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
    error NoCashForMint();
    error SupplyExceeded();
    error AddressQuantityExceeded();
    error NoFilthyMintYet();
    error NoCorpoMintYet();
    error NoBotMintYet();
    error CantMintThisFilthy();
    error CantMintCorpo();
    error CantImplantNow();
    error PeasantAlreadyMinted();
    error ChipDoesNotExist();
    error CantIncreaseSupply();

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
    //                        MAKING THE DEAL
    // =============================================================

    function implant(uint256 cardId_) external nonReentrant() {
        // If implanting is closed, you can't make a deal brother.
        if (!canImplant) revert CantImplantNow();
        // If you are not owner you can't make a deal.
        // We don't need to check the ownership here.
        // _burn will revert if you are not the owner.
        // Thus I think we can comment this shit out.
        // if (_msgSenderERC721A() != ownerOf(cardId_)) revert NotYourMemoryChip();
        // Burn this token.
        _burn(cardId_, true);
        // We will be using other contract.
        GigaCityContract factory = GigaCityContract(gigaCityContract);
        // And finally mint a new one.
        factory.implant(_msgSenderERC721A());
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
        if (msg.value < mintPrice * quantity_) revert NoCashForMint();
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
        if (FilthyPeasantsContract(filthyContract).ownerOf(peasantId_) != _msgSenderERC721A()) revert CantMintThisFilthy();
        // Has the peasant been redeemed?
        if (_peasantsMinted[peasantId_] == true) revert PeasantAlreadyMinted();
        // If not, it is redeemed now
        _peasantsMinted[peasantId_] = true;
        // We need to know how many filthys have minted
        _filthyMintCounter += 1;
        // And we finally mint.
        _mint(_msgSenderERC721A(), 2);
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
        bytes32 leaf = keccak256(abi.encodePacked(_msgSenderERC721A()));
        if (!MerkleProofLib.verify(proof_, _corpoRoot, leaf)) revert CantMintCorpo();
        // Do you have enough cash?
        _hasEnoughCash(quantity_);
        // We continue minting. 
        _mint(_msgSenderERC721A(), quantity_);
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
        _mint(_msgSenderERC721A(), quantity_);
    }

    // =============================================================
    //                              INFO
    // =============================================================

    function chipsImplanted(address addr_) external view returns (uint256) {
        return _numberBurned(addr_);
    }

    function totalChipsImplanted() external view returns (uint256) {
        return _totalBurned();
    }

    function peasantMinted(uint256 peasantId_) external view returns (bool) {
        return _peasantsMinted[peasantId_] == true;
    }

    function totalPeasantsMinted() external view returns (uint256) {
        return _filthyMintCounter;
    }

    // =============================================================
    //                              METADATA
    // =============================================================

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId_) public view virtual override(ERC721A, IERC721A) returns (string memory) {
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

    function setGigaCityContract(address contractAddress_) external onlyOwner {
        gigaCityContract = contractAddress_;
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

        supplyCap = supplyCap_;
    }

    function toggleCorpoMint() public onlyOwner {
        corpoMint = !corpoMint;
    }

    function toggleBotMint() external onlyOwner {
        botMint = !botMint;
    }

    function toggleImplant() external onlyOwner {
        canImplant = !canImplant;
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