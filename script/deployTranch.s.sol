// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {Constants} from './Utils/Constants.arbitrum.goerli.sol';
import {LPToken} from "../src/tokens/LPToken.sol";

/**
 * @title Deployment Script For LPToken contracts
 * @notice Contracts Deployed : LPToken
 */
contract DeployScript is Script {

    function run() external {
        uint256 deployer = vm.envUint("PRIVATE_KEY");

        address deployerPublicKey = vm.rememberKey(deployer);
        vm.startBroadcast(deployerPublicKey);

        LPToken seniorTranch = new LPToken("RWAX_SENIOR_LLP", "RWAX_SN", Constants.LP_TOKEN_MINTER);
        LPToken juniorTranch = new LPToken("RWAX_JUNIOR_LLP", "RWAX_JN", Constants.LP_TOKEN_MINTER);

        vm.stopBroadcast();
    }
}
