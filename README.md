## Deployment Procedure

1. Load the variables in the .env file
```
source .env
```

2. Deploy and verify our contracts
```
forge script script/Deploy.s.sol:DeployScript --rpc-url $ARBITRUM_GOERLI_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify  $ETHERSCAN_API_KEY -vvvv
```

3. Deploy Pool separately if needed
```
forge script script/DeployPool.s.sol:DeployScript --rpc-url $ARBITRUM_GOERLI_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify  $ETHERSCAN_API_KEY -vvvv
```

4. Deploy Fee Distributor separately if needed
```
forge script script/deployFeeDistributor.s.sol:DeployScript --rpc-url $ARBITRUM_GOERLI_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify  $ETHERSCAN_API_KEY -vvvv
```


### Deployed Contract Addresses

```
{
"USDC":"0x5a27B97745751036fd8A8D3A5e40181991c64481",
"Index":"0x72A7E70D38b04381556d0395bF0aF0e193587Fb5",
"ProxyAdmin":"0xeBF844B3b320E0Ca03597300e6e8c545f7F21FFc",
"RwaxOracle":"0x4580fe01a599976cE363D9dD86Bac8489A21c094",
"ETHUnwrapper":"0xe085a655deAAd92D516f348CFbA97De96BBd736c",
"OrderManager":"0x21eb064040ec2eEF473fA3EC50c2c379f52026D1",
"Order Manager Proxy":"0x944872e03E13277969DA23C7F72EcB0B59c5f02D",
"OrderHook":"0x4C4740350390807F9D417D0Ed7cE03A328e48BD9",
"Pool":"0x8b6092AbdB90Bd7805F1F0e92515342F5b67E31a",
"Pool Proxy":"0x4B8a792057249fbc55d45E6f6642aEd623277f13",
"PoolHook":"0x85243Bfe4A01333822D6DD8669822ad2d1679AbA",
"LiquidityRouter":"0x9D1E33a9c7f84331b0A95F7853ec90F058b9fa64",
"Senior Tranch":"0x7658D6cf10Ae2679e55C7983E71A89ef0795a8Bf",
"Middle Tranch":"0x5972ebc61B29d09241f7a2849C16b282F191F6E2",
"Junior Tranch":"0x8A48b97AFdE71FD0084fD8a0BfaFD67dC426E50c",
"PriceReporter":"0xF3Cf34aB09bbF576302B5EcF720280e8f60667Ae",
"TradeExecutor":"0xC55Bb929edFe12621cFdef269b7a3B2991b70B1a",
"FeeDistributor":"0x7F6f20a99Ab54246bd120a1Df87E64F87bAf269C",
"Testnet Version": "0.1",
"Network": "Arbitrum Goerli"
}

```