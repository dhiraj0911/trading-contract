// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {Constants} from './Utils/Constants.arbitrum.goerli.sol';
import {Pool} from "../src/pool/Pool.sol";
import {FeeDistributor} from "../src/pool/FeeDistributor.sol";

/**
 * @title Deployment Script For Oracle Related contracts
 * @notice Contracts Deployed : RWAX Oracle
 */
contract DeployScript is Script {

    function run() external {
        uint256 deployer = vm.envUint("PRIVATE_KEY");

        address deployerPublicKey = vm.rememberKey(deployer);
        vm.startBroadcast(deployerPublicKey);

        Pool liquidityPool = Pool(Constants.LIQUIDITY_POOL);
        
        FeeDistributor feeDistributor = new FeeDistributor(address(liquidityPool));

        ///@dev Set tokens for fees distributor
        liquidityPool.setFeeDistributor(address(feeDistributor));

        vm.stopBroadcast();
    }
}
