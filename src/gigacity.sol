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
// Nothing is as it might seem in the streets of GC. In the
// shadows of the few prosperous lies the filth of the eye.
//
// High in the sky where decisions are made is the proof of
// those leading the path but not being seen. The truth is
// there but nothing can find it.
//
// Only in the eyes of those truly worthy the truth will be
// revealed. 50b ...

// =============================================================
//                       GIGA CITY PUNKS
// =============================================================

contract GigaCity is
    ERC721AQueryable,
    ReentrancyGuard,
    Ownable {

    // Where is MC at?
    address public memoryChipContract;

    // Where are our assets hosted?
    string private _baseTokenURI;

    // Once/if we will transition to IPFS this will come in handy
    string private _uriSuffix = '';

    // This is not used for anything in this contract.
    // While it is most likely an overkill to include something like this
    // in a contract, it is transparent.
    bool public initiateCountdown;

    // =============================================================
    //                            ERRORS
    // =============================================================

    error CitizenDoesNotExist();
    error NotAMemoryChip();
    error WithdrawlFailed();
    error PunkNotStaked();
    error PunkIsStaked();
    error NotYourPunk();
    error StakingClosed();

    // =============================================================
    //                            CONSTRUCTOR
    // =============================================================

    constructor(
        address memoryChipContract_
    ) ERC721A(
        "Giga City",
        "GC"
    ) Ownable(msg.sender) {
        memoryChipContract = memoryChipContract_;
        initiateCountdown = false;
    }

    // =============================================================
    //                          MAKING THE DEAL
    // =============================================================

    function implant(address to) external nonReentrant() {
        // it needs to be the MC contract
        if (_msgSenderERC721A() != memoryChipContract) revert NotAMemoryChip();
        // Safe mint since minting through contract
        _safeMint(to, 1);
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
        if (!_exists(tokenId_)) revert CitizenDoesNotExist();

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

    function setURISuffix(string calldata uriSuffix_) public onlyOwner {
        _uriSuffix = uriSuffix_;
    }

    function setCountdown(bool newCountdown_) public onlyOwner {
        initiateCountdown = newCountdown_;
    }


    // =============================================================
    //                           OWNABLE
    // =============================================================

    /**
     * @dev Override needed due to fonflict. Super.owner() returns
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
}
