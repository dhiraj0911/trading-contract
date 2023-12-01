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
        uint256 eoaReporter = vm.envUint("PRIVATE_KEY_EOA_REPORTER");
        eoaReporterPublicKey = vm.rememberKey(eoaReporter);

        vm.startBroadcast(deployerPublicKey);
        _bind();
        __deployPriceReporter();
        vm.stopBroadcast();

    }

    function _bind() internal {

        usdc = MockERC20(0x5a27B97745751036fd8A8D3A5e40181991c64481);
        index1 = Index(0x72A7E70D38b04381556d0395bF0aF0e193587Fb5);
        rwaxOracle = RwaxOracle(0x4580fe01a599976cE363D9dD86Bac8489A21c094);
        orderManager = OrderManager(payable(0x944872e03E13277969DA23C7F72EcB0B59c5f02D));
    }

    function __deployPriceReporter() internal {

        priceReporter = new PriceReporter(address(rwaxOracle),address(orderManager));

        priceReporter.addReporter(eoaReporterPublicKey);
        orderManager.setExecutor(address(priceReporter));
        rwaxOracle.addReporter(address(priceReporter));
    }

}
