// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/filthypeasants.sol";
import "src/memorychip.sol";
import "src/gigacity.sol";

contract Deploy is Script {
    function run() external {
        // Use a bytes literal for the default value to disambiguate the overload.
        bytes memory defaultMnemonicBytes = bytes("test test test test test test test test test test test junk");
        // This call will now choose the bytes overload and return bytes, which we then convert to string.
        string memory mnemonic = string(vm.envOr("MNEMONIC", defaultMnemonicBytes));

        // Derive the private keys for account positions 0 and 1.
        uint256 deployerPrivateKey = vm.deriveKey(mnemonic, 0);
        uint256 user1 = vm.deriveKey(mnemonic, 1);

        // Derive the corresponding addresses.
        address addr0 = vm.addr(deployerPrivateKey);
        address addr1 = vm.addr(user1);

        // Log the addresses.
        console.log("Address(0): ", addr0);
        console.log("Address(1): ", addr1);
        
        vm.startBroadcast(deployerPrivateKey);

        FilthyPeasants filthyPeasants = new FilthyPeasants('Filthy Peasants', 'Filthy', 0, 100, 10);
        console.log("FilthyPeasants deployed to:", address(filthyPeasants));
        filthyPeasants.setPaused(false);

        MemoryChip memoryChip = new MemoryChip(address(filthyPeasants), 100, 10);
        console.log("Memory Chip deployed to:", address(memoryChip));

        GigaCity gigaCity = new GigaCity(address(memoryChip));
        console.log("GigaCity deployed to:", address(gigaCity));

        memoryChip.setBaseURI('https://beacon-api.gigacity.org/mc/');
        memoryChip.setGigaCityContract(address(gigaCity));

        memoryChip.toggleFilthyMint();
        memoryChip.toggleCorpoMint();
        memoryChip.toggleBotMint();

        memoryChip.setCorpoRoot(0x48c27779a144877a7a0cd10e324c97f13e7e3f6839dde90f1659c26a13cf5ac5);

        memoryChip.toggleImplant();

        gigaCity.setBaseURI('https://beacon-api.gigacity.org/punks/');

        vm.stopBroadcast();

        vm.startBroadcast(user1);

        filthyPeasants.mint(2);

        vm.stopBroadcast();
    }
}