// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {Constants} from './Utils/Constants.arbitrum.goerli.sol';
import {PriceReporter} from "../src/keeper/PriceReporter.sol";
import {TradeExecutor} from "../src/keeper/TradeExecutor.sol";

/**
 * @title Deployment Script For Oracle Related contracts
 * @notice Contracts Deployed : RWAX Oracle
 */
contract DeployScript is Script {

    function run() external {
        uint256 deployer = vm.envUint("PRIVATE_KEY");

        address deployerPublicKey = vm.rememberKey(deployer);
        vm.startBroadcast(deployerPublicKey);

        PriceReporter priceReporter = new PriceReporter(Constants.ORACLE,Constants.ORDER_MANAGER);
        TradeExecutor tradeExecutor = new TradeExecutor(Constants.LIQUIDITY_POOL, address(priceReporter));

        priceReporter.addReporter(Constants.PRICE_REPORTER_EOA);

        address[] memory feeTokens = new address[](2);
        feeTokens[0] = Constants.FEE_TOKEN_1;
        feeTokens[1] = Constants.FEE_TOKEN_2;
        tradeExecutor.updateFeeTokens(feeTokens);

        vm.stopBroadcast();
    }
}
