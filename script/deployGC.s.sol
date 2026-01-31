// script/DeployHelloWorld.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/gigacity.sol";

contract DeployScript is Script {

    function run() public {
        // address deployer=0x53A35BAb3c6502b7a5e3298492DBBc3A51230545;
        address CREATE2_FACTORY = 0x0000000000FFe8B47B3e2130213B802212439497;
        bytes32 salt = 0x53a35bab3c6502b7a5e3298492dbbc3a51230545ec47771d366ff903996d764a;
        address expectedAddress = 0x000000000075381bc3a5dF2296a8D9997175FE50;

        // Check if already deployed
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(expectedAddress)
        }
        require(codeSize == 0, "Contract already deployed at target address");

        bytes memory creationCode = abi.encodePacked(
            type(GigaCity).creationCode,
            abi.encode(
                0x8d7AeD5CDB023c4c1686719fe9D74c4a48923668
        ));
        
        vm.broadcast();  // Uses the private key provided via Forge command
        (bool success, ) = CREATE2_FACTORY.call(
            abi.encodeWithSignature("safeCreate2(bytes32,bytes)", salt, creationCode)
        );
        require(success, "Deployment failed");
    }
}