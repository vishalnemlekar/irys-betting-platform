// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";
import "../src/TemporaryDeployFactory.sol";

contract DeployScript is Script {
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Record logs before deployment
        vm.recordLogs();

        // Deploy factory (which deploys BettingPlatform and self-destructs)
        TemporaryDeployFactory factory = new TemporaryDeployFactory();

        // Parse ContractsDeployed event
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 eventSignature = keccak256("ContractsDeployed(address,string[],address[])");

        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == eventSignature && logs[i].emitter == address(factory)) {
                // Extract deployer from indexed parameter
                address deployer = address(uint160(uint256(logs[i].topics[1])));

                // Decode dynamic arrays from event data
                (string[] memory contractNames, address[] memory contractAddresses) =
                    abi.decode(logs[i].data, (string[], address[]));

                console.log("==============================================");
                console.log("Deployment successful!");
                console.log("==============================================");
                console.log("Deployer:", deployer);
                console.log("Factory Address:", address(factory));
                console.log("Contracts deployed:", contractNames.length);
                console.log("");

                // Log all deployed contracts
                for (uint256 j = 0; j < contractNames.length; j++) {
                    console.log("Contract:", contractNames[j]);
                    console.log("Address:", contractAddresses[j]);
                    console.log("----------------------------------------------");
                }

                console.log("==============================================");
                break;
            }
        }

        vm.stopBroadcast();
    }
}
