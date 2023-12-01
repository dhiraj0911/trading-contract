// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {Constants} from './Utils/Constants.arbitrum.goerli.sol';
import {TransparentUpgradeableProxy} from "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin/proxy/transparent/ProxyAdmin.sol";
import {Pool, TokenWeight} from "../src/pool/Pool.sol";
import {LiquidityRouter} from "../src/pool/LiquidityRouter.sol";
import {PoolHook} from "../src/hooks/PoolHook.sol";
import {PriceReporter} from "../src/keeper/PriceReporter.sol";
import {TradeExecutor} from "../src/keeper/TradeExecutor.sol";
import {RwaxOracle} from "../src/oracle/RwaxOracle.sol";
import "../src/orders/OrderManager.sol";
import {ETHUnwrapper} from "../src/orders/ETHUnwrapper.sol";
import {LPToken} from "../src/tokens/LPToken.sol";
import {OrderHook} from "../src/orders/OrderHook.sol";
import {FeeDistributor} from "../src/pool/FeeDistributor.sol";
import {MockERC20} from "./Utils/MockERC20.sol";
import {Index} from "../src/index/Index.sol";

contract DeployScript is Script {

    ProxyAdmin public proxyAdmin;
    Pool public liquidityPool;
    LiquidityRouter public router;
    PoolHook public poolHook;

    LPToken public seniorTranch;
    LPToken public juniorTranch;
    LPToken public middleTranch;

    ETHUnwrapper public ethUnwrapper;
    OrderManager public orderManager;
    OrderHook    public orderHook;

    PriceReporter public priceReporter;
    TradeExecutor public tradeExecutor;
    
    RwaxOracle public rwaxOracle;
    FeeDistributor public feeDistributor;

    MockERC20 public usdc;
    Index public index1;

    address public deployerPublicKey;
    address public eoaReporterPublicKey;

    function run() public {
        uint256 deployer = vm.envUint("PRIVATE_KEY");
        deployerPublicKey = vm.rememberKey(deployer);
        vm.startBroadcast(deployerPublicKey);
        _bind();
        vm.stopBroadcast();

        uint256 eoaReporter = vm.envUint("PRIVATE_KEY_EOA_REPORTER");
        eoaReporterPublicKey = vm.rememberKey(eoaReporter);
        vm.startBroadcast(eoaReporterPublicKey);
        _executeOrders();
        vm.stopBroadcast();

    }

    function _dealUSDC(uint256 amount) internal {
        usdc.mint(amount);
    }

    function _bind() internal {
        usdc = MockERC20(0x5a27B97745751036fd8A8D3A5e40181991c64481);
        index1 = Index(0x72A7E70D38b04381556d0395bF0aF0e193587Fb5);
        priceReporter = PriceReporter(0xF3Cf34aB09bbF576302B5EcF720280e8f60667Ae);
    }

    function _executeOrders() internal {

/**
        uint256[] memory orders = new uint256[](2);
        orders[0] = 1;
        orders[1] = 3;


        address[] memory tokens = new address[](2);
        tokens[0] =  address(usdc);
        tokens[1] =  address(index1);

        uint256[] memory prices = new uint256[](2);
        prices[0] =  1e6;
        prices[1] =  2e6; // 2USD

        priceReporter.postPriceAndExecuteOrders(tokens, prices, orders );
*/

        uint256[] memory newOrders = new uint256[](2);
        newOrders[0] = 2;
        newOrders[1] = 4;

        address[] memory tokens = new address[](2);
        tokens[0] =  address(usdc);
        tokens[1] =  address(index1);
        
        uint256[] memory newPrices = new uint256[](2);
        newPrices[0] =  1e6;
        newPrices[1] =  21e5; // 2USD

        priceReporter.postPriceAndExecuteOrders(tokens, newPrices, newOrders );

    }

}
