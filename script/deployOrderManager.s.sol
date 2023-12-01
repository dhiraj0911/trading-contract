// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {Constants} from './Utils/Constants.arbitrum.goerli.sol';
import {TransparentUpgradeableProxy} from "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin/proxy/transparent/ProxyAdmin.sol";
import {OrderManager} from "../src/orders/OrderManager.sol";
import {ETHUnwrapper} from "../src/orders/ETHUnwrapper.sol";

/**
 * @title Deployment Script For Order Manager Related contracts
 * @notice Contracts Deployed : ETHUnwrapper, Order Manager Implementation,
 *                              Order Manager Proxy, Proxy Admin
 */
contract DeployScript is Script {

    function run() external {
        uint256 deployer = vm.envUint("PRIVATE_KEY");

        address deployerPublicKey = vm.rememberKey(deployer);
        vm.startBroadcast(deployerPublicKey);

        ETHUnwrapper ethUnwrapper = new ETHUnwrapper(address(Constants.WETH));

        OrderManager orderManagerImpl = new OrderManager(); // Deploy Implementation contracts
        ProxyAdmin proxyAdmin = new ProxyAdmin(); // Deploy proxy Admin
        bytes memory data = abi.encodeWithSignature("initialize(address,address,uint256,address)", Constants.WETH,
            Constants.ORACLE,
            Constants.MIN_PERPETUAL_EXECUTION_FEE,
            address(ethUnwrapper));

        // Deploy Proxy calling initialize as well
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(orderManagerImpl),
            address(proxyAdmin),
            data);

        // Cast proxy to orderManager
        OrderManager orderManager = OrderManager(payable(address(proxy)));

        orderManager.setOracle(Constants.ORACLE);
        orderManager.setPool(Constants.LIQUIDITY_POOL);
        orderManager.setMinExecutionFee(Constants.MIN_PERPETUAL_EXECUTION_FEE, Constants.MIN_SWAP_EXECUTION_FEE);
        orderManager.setOrderHook(Constants.ORDER_HOOK);
        orderManager.setExecutor(Constants.ORDER_EXECUTOR);

        vm.stopBroadcast();
    }
}
