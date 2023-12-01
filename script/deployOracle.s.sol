// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {Constants} from './Utils/Constants.arbitrum.goerli.sol';
import {RwaxOracle} from "../src/oracle/RwaxOracle.sol";

/**
 * @title Deployment Script For Oracle Related contracts
 * @notice Contracts Deployed : RWAX Oracle
 */
contract DeployScript is Script {

    function run() external {
        uint256 deployer = vm.envUint("PRIVATE_KEY");

        address deployerPublicKey = vm.rememberKey(deployer);
        vm.startBroadcast(deployerPublicKey);

        RwaxOracle oracle = new RwaxOracle();

        ///@dev This will change based on New oracle from Redstone or API3
        //oracle.configToken()

        oracle.addReporter(Constants.ORACLE_REPORTER);

        vm.stopBroadcast();
    }
}
