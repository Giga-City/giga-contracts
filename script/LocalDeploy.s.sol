// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
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

        GigaCity gigaCity = new GigaCity(addr0);
        console.log("GigaCity deployed to:", address(gigaCity));

        gigaCity.setBaseURI('https://beacon-api.gigacity.org/punks/');
        gigaCity.setMintPrice(3300000000000000);
        gigaCity.toggleBotMint();

        vm.stopBroadcast();

        // vm.startBroadcast(user1);

        // vm.stopBroadcast();
    }
}