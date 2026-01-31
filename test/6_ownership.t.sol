// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./_deploySetup.sol";

// Mock CREATE2 Factory contract for testing
contract MockCREATE2Factory {
    event Deployed(address addr, bytes32 salt);

    function deploy(bytes32 salt, bytes memory bytecode) public returns (address) {
        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "CREATE2: Failed on deploy");
        emit Deployed(addr, salt);
        return addr;
    }
}

contract OwnershipTest is DeploySetup {
    MockCREATE2Factory public factory;

    function setUp() public override {
        owner = address(this);

        user1 = vm.addr(1);
        user2 = vm.addr(2);
        user3 = vm.addr(3);

        vm.deal(owner, 1 ether);
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
        vm.deal(user3, 1 ether);

        factory = new MockCREATE2Factory();
    }

    function testOwnerIsSetCorrectlyInConstructor() public {
        // Deploy with specific owner
        address expectedOwner = user1;
        GigaCity gc = new GigaCity(expectedOwner);

        assertEq(gc.owner(), expectedOwner, "Owner should be the address passed to constructor");
    }

    function testOwnerIsNotDeployer() public {
        // Deploy from this contract but set owner to user1
        address expectedOwner = user1;
        GigaCity gc = new GigaCity(expectedOwner);

        assertEq(gc.owner(), expectedOwner, "Owner should be user1");
        assertTrue(gc.owner() != address(this), "Owner should not be the deployer");
    }

    function testCREATE2FactoryDeploymentOwnership() public {
        // Set up the deployment
        address intendedOwner = user1;

        // Create the deployment bytecode with constructor args
        bytes memory bytecode = abi.encodePacked(
            type(GigaCity).creationCode,
            abi.encode(intendedOwner)
        );

        bytes32 salt = keccak256("test-salt");

        // Deploy through factory
        address deployedAddress = factory.deploy(salt, bytecode);

        // Cast to GigaCity
        GigaCity gc = GigaCity(deployedAddress);

        // Verify owner is the intended owner, NOT the factory
        assertEq(gc.owner(), intendedOwner, "Owner should be intendedOwner");
        assertTrue(gc.owner() != address(factory), "Owner should not be the factory");

        // Verify intended owner can call owner functions
        vm.prank(intendedOwner);
        gc.setMintPrice(0.05 ether);
        assertEq(gc.mintPrice(), 0.05 ether, "Intended owner should be able to set mint price");
    }

    function testCREATE2FactoryCannotCallOwnerFunctions() public {
        // Set up the deployment
        address intendedOwner = user1;

        bytes memory bytecode = abi.encodePacked(
            type(GigaCity).creationCode,
            abi.encode(intendedOwner)
        );

        bytes32 salt = keccak256("test-salt-2");
        address deployedAddress = factory.deploy(salt, bytecode);
        GigaCity gc = GigaCity(deployedAddress);

        // Factory should NOT be able to call owner functions
        vm.prank(address(factory));
        vm.expectRevert();
        gc.setMintPrice(0.05 ether);
    }

    function testDeployerCannotCallOwnerFunctions() public {
        // Deploy from this contract but set owner to user1
        address expectedOwner = user1;
        GigaCity gc = new GigaCity(expectedOwner);

        // Deployer (this contract) should NOT be able to call owner functions
        vm.expectRevert();
        gc.setMintPrice(0.05 ether);
    }

    function testOwnerCanWithdraw() public {
        address expectedOwner = user1;
        GigaCity gc = new GigaCity(expectedOwner);

        // Send some ETH to the contract
        vm.deal(address(gc), 1 ether);

        uint256 balanceBefore = expectedOwner.balance;

        // Owner should be able to withdraw
        vm.prank(expectedOwner);
        gc.withdraw();

        assertEq(expectedOwner.balance, balanceBefore + 1 ether, "Owner should receive withdrawn funds");
    }

    function testNonOwnerCannotWithdraw() public {
        address expectedOwner = user1;
        GigaCity gc = new GigaCity(expectedOwner);

        // Send some ETH to the contract
        vm.deal(address(gc), 1 ether);

        // Non-owner should NOT be able to withdraw
        vm.prank(user3);
        vm.expectRevert();
        gc.withdraw();
    }

    function testRoyaltyReceiverIsIndependentOfOwner() public {
        address owner = user1;
        GigaCity gc = new GigaCity(owner);

        // Mint a token to test royalty info
        vm.prank(owner);
        gc.mintTreasury(user3, 1);

        // Check royalty info
        (address receiver, uint256 royaltyAmount) = gc.royaltyInfo(1, 10000);

        assertEq(receiver, owner, "Royalty receiver should be set correctly");
        assertEq(royaltyAmount, 333, "Royalty amount should be 333 (3.33%)");
    }
}
