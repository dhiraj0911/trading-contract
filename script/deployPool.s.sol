
// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {Constants} from './Utils/Constants.arbitrum.goerli.sol';
import {TransparentUpgradeableProxy} from "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin/proxy/transparent/ProxyAdmin.sol";
import {Pool} from "../src/pool/Pool.sol";
import {LiquidityRouter} from "../src/pool/LiquidityRouter.sol";
import {PoolHook} from "../src/hooks/PoolHook.sol";

/**
 * @title Deployment Script For Pool Related contracts
 * @notice Contracts Deployed : Pool Implementation, Pool Proxy, 
 *                              Pool Proxy Admin, LiquidityRouter, Pool Hook
 */
contract DeployScript is Script {

    Pool public liquidityPool;

    function run() external {

        uint256 deployer = vm.envUint("PRIVATE_KEY");
        address deployerPublicKey = vm.rememberKey(deployer);
        vm.startBroadcast(deployerPublicKey);
        
        Pool pool = new Pool(); // Deploy Implementation contracts
        ProxyAdmin proxyAdmin = new ProxyAdmin(); // Deploy proxy Admin

        // Deploy Proxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(pool),
            address(proxyAdmin),
            new bytes(0));

        // Cast proxy to pool
        liquidityPool = Pool(address(proxy));
        liquidityPool.initialize();
        // Initializing 
        liquidityPool.setMaxLeverage(Constants.MAX_LEVERAGE);
        liquidityPool.setMaintenanceMargin(Constants.MAINTENANCE_MARGIN);
        liquidityPool.setPositionFee(Constants.POSITION_FEE, Constants.LIQUIDATION_FEE);
        liquidityPool.setInterestRate(Constants.INTEREST_RATE, Constants.ACCRUAL_INTERVAL);
        liquidityPool.setSwapFee(Constants.BASE_SWAP_FEE,
            Constants.STABLE_BASE_SWAP_FEE,
            Constants.TAX_BASIS_POINT,
            Constants.STABLE_TAX_BASIS_POINT);
        liquidityPool.setAddRemoveLiquidityFee(Constants.ADD_REMOVE_LIQUIDITY_FEE);
        liquidityPool.setDaoFee(Constants.DAO_FEE);

        // Linking
        liquidityPool.setOracle(Constants.ORACLE);
        liquidityPool.setOrderManager(Constants.ORDER_MANAGER);
        liquidityPool.setFeeDistributor(Constants.FEE_DISTRIBUTOR);

        // Setting Tokens
        liquidityPool.addToken(Constants.USDC, true);
        
        /// @dev Skip This for stables
        //liquidityPool.setRiskFactor(Constant.USDC, Constants.USDC_RISK_CONFIG);

        ///@dev set Risk factor for index Tokens, This is important for reserver asset calculations
        
        // Setting Max Short Size and Max long size for an index
        liquidityPool.addToken(Constants.INDEX_1, false);
        liquidityPool.setMaxGlobalShortSize(Constants.INDEX_1, Constants.MAX_SHORT_SIZE_INDEX_1);
        liquidityPool.setMaxGlobalLongSizeRatio(Constants.INDEX_1, Constants.MAX_LONG_SIZE_RATIO_INDEX_1);

        vm.stopBroadcast();

    }
}