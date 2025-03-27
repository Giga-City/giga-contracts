// script/DeployHelloWorld.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/gigacity.sol";

contract DeployScript is Script {
    function run() public {
        address deployer=0x237DE2eC3D2caF5B85EFa2312EC1c0D77B4219Dc;
        address CREATE2_FACTORY = 0x0000000000FFe8B47B3e2130213B802212439497;
        bytes32 salt = 0x237de2ec3d2caf5b85efa2312ec1c0d77b4219dc49ec102b7f33ec03da00d029;
        address expectedAddress = 0x0000000000000B265678265bA5692Db0698C871b;

        // Check if already deployed
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(expectedAddress)
        }
        require(codeSize == 0, "Contract already deployed at target address");

        bytes memory creationCode = abi.encodePacked(
          type(GigaCity).creationCode,
          abi.encode(
              0x000000000000763B5B437cFC2F41249ABC045937,
              deployer
        ));
        
        vm.broadcast();  // Uses the private key provided via Forge command
        (bool success, ) = CREATE2_FACTORY.call(
            abi.encodeWithSignature("safeCreate2(bytes32,bytes)", salt, creationCode)
        );
        require(success, "Deployment failed");
    }
}