// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./BettingPlatform.sol";

/**
 * @title TemporaryDeployFactory
 * @notice EIP-6780 compliant factory for deploying BettingPlatform contract
 * @dev Uses parameter-free constructor for universal multi-chain deployment
 */
contract TemporaryDeployFactory {
    /// @notice Emitted when contracts are deployed
    event ContractsDeployed(
        address indexed deployer,
        string[] contractNames,
        address[] contractAddresses
    );

    constructor() {
        // Deploy BettingPlatform contract
        BettingPlatform bettingPlatform = new BettingPlatform();

        // Build contract info arrays
        string[] memory contractNames = new string[](1);
        contractNames[0] = "BettingPlatform";

        address[] memory contractAddresses = new address[](1);
        contractAddresses[0] = address(bettingPlatform);

        // Emit event with deployment info
        emit ContractsDeployed(msg.sender, contractNames, contractAddresses);

        // Self-destruct and return remaining gas to deployer
        selfdestruct(payable(msg.sender));
    }
}
