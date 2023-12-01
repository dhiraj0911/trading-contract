// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract DeployScript is Script {

    address public eoaReporterPublicKey;

    function run() public {

        uint256 eoaReporter = vm.envUint("PRIVATE_KEY_EOA_REPORTER");
        eoaReporterPublicKey = vm.rememberKey(eoaReporter);

        vm.startBroadcast(eoaReporter);
        console.log(eoaReporterPublicKey);
        vm.stopBroadcast();


    }
}