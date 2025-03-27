<p>
  <img src="./cover.jpg" width="800">
  <br>
</p>

## Giga City Contracts

Includes various contracts from Giga City ecosystem. Written in solidity, maintained with [Forge by Foundry](https://book.getfoundry.sh/).

## Usage

- `$ forge build` - Build contracts
- `$ forge test` - Run tests
- `$ forge coverage` - Run tests and show test coverage
- `$ forge snapshot` - Gas snapshot

To get the bytecode, run: `forge script script/GetByteCode.sol --sig "testGetInitHash()"`

## Contracts

- `memorychip.sol` - Contract for minting unrevealed Giga City assets.
- `gigacity.sol` - Contract for revealed Giga City assets.
- `filthypeasants.sol` - Contract is included for testing Filthy minting of MCs.

## Deployment

You can deploy the contracts with the following command:
```
forge create MemoryChip --broadcast --rpc-url "{RPC}" --private-key {PK} --constructor-args {filthy_peasants_contract} {supply} {max mint per addy} {owner}
```

and then verify like follows:
```
forge verify-contract {contract address} MemoryChip --chain-id {chain_id} --etherscan-api-key {etherscan api} --constructor-args $(cast abi-encode "constructor(address,uint256,uint256,address)" "{filthy_peasants_contract}" {supply} {max mint per addy} "{owner}")
```

and GC contract:
```
forge create GigaCity --broadcast --rpc-url "https://ethereum-sepolia-rpc.publicnode.com" --private-key {PK} --constructor-args {memory chip contract addy} {owner}
```

and then verify:
```
forge verify-contract {contract address} GigaCity --chain-id {chain_id} --etherscan-api-key {etherscan api} --constructor-args $(cast abi-encode "constructor(address)" "{mc_contract}" "{owner}")
```

## Local Anvil testing

With the last update, I added an option to deploy contracts to local anvil, so that the testing is a bit easier.

With one terminal, run local anvil node, with block time: 3s.

``` 
anvil --block-time 3
```

And then deploy all the necessary contracts with second terminal. Now all the contracts will be minted, and open for minting and implanting. No other necessary action needed. Account (1) will also have two filthy peasants to test Filthy Mint.

``` 
forge script script/LocalDeploy.s.sol --fork-url http://127.0.0.1:8545 --broadcast
```

