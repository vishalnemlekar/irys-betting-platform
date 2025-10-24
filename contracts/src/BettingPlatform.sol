// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title BettingPlatform
 * @notice A decentralized betting platform where users can create bets, invest in outcomes, and claim rewards
 * @dev Implements reentrancy protection and access control for secure betting operations
 */
contract BettingPlatform is Ownable, ReentrancyGuard {
    /// @notice Platform fee percentage (2% = 200 basis points)
    uint256 public constant PLATFORM_FEE_BPS = 200;
    uint256 public constant BPS_DENOMINATOR = 10000;

    /// @notice Counter for bet IDs
    uint256 public nextBetId;

    /// @notice Struct to store bet information
    struct Bet {
        address creator;
        string title;
        string description;
        string[] outcomes;
        uint256 investmentDeadline;
        uint256 settlementDeadline;
        string irysTxId;
        bool settled;
        uint256 winningOutcomeIndex;
        bool exists;
    }

    /// @notice Struct to track outcome pool information
    struct OutcomePool {
        uint256 totalAmount;
        mapping(address => uint256) investments;
        address[] investors;
    }

    /// @notice Mapping from bet ID to Bet struct
    mapping(uint256 => Bet) public bets;

    /// @notice Mapping from bet ID to outcome index to OutcomePool
    mapping(uint256 => mapping(uint256 => OutcomePool)) public outcomePools;

    /// @notice Mapping to track if user has claimed rewards for a bet
    mapping(uint256 => mapping(address => bool)) public hasClaimed;

    /// @notice Mapping to track total pool for each bet (for fee calculation)
    mapping(uint256 => uint256) public betTotalPools;

    /// @notice Mapping to track platform fee for each bet
    mapping(uint256 => uint256) public betPlatformFees;

    /// @notice Accumulated platform fees
    uint256 public accumulatedFees;

    /// @notice Emitted when a new bet is created
    event BetCreated(
        uint256 indexed betId,
        address indexed creator,
        string title,
        string[] outcomes,
        uint256 investmentDeadline,
        uint256 settlementDeadline,
        string irysTxId
    );

    /// @notice Emitted when a user invests in an outcome
    event InvestmentMade(
        uint256 indexed betId,
        address indexed investor,
        uint256 outcomeIndex,
        uint256 amount
    );

    /// @notice Emitted when a bet is settled
    event BetSettled(
        uint256 indexed betId,
        uint256 winningOutcomeIndex,
        uint256 totalPool,
        uint256 platformFee
    );

    /// @notice Emitted when rewards are claimed
    event RewardsClaimed(
        uint256 indexed betId,
        address indexed investor,
        uint256 amount
    );

    /// @notice Emitted when platform fees are withdrawn
    event FeesWithdrawn(address indexed owner, uint256 amount);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Create a new bet
     * @param title The title of the bet
     * @param description The description of the bet
     * @param outcomes Array of possible outcome strings
     * @param investmentDeadline Timestamp when investments close
     * @param settlementDeadline Timestamp when bet should be settled
     * @param irysTxId Irys transaction ID for permanent storage reference
     * @return betId The ID of the created bet
     */
    function createBet(
        string memory title,
        string memory description,
        string[] memory outcomes,
        uint256 investmentDeadline,
        uint256 settlementDeadline,
        string memory irysTxId
    ) external returns (uint256 betId) {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(outcomes.length >= 2, "At least 2 outcomes required");
        require(investmentDeadline > block.timestamp, "Investment deadline must be in future");
        require(settlementDeadline > investmentDeadline, "Settlement deadline must be after investment deadline");
        require(bytes(irysTxId).length > 0, "Irys TX ID cannot be empty");

        betId = nextBetId++;

        Bet storage bet = bets[betId];
        bet.creator = msg.sender;
        bet.title = title;
        bet.description = description;
        bet.outcomes = outcomes;
        bet.investmentDeadline = investmentDeadline;
        bet.settlementDeadline = settlementDeadline;
        bet.irysTxId = irysTxId;
        bet.settled = false;
        bet.exists = true;

        emit BetCreated(
            betId,
            msg.sender,
            title,
            outcomes,
            investmentDeadline,
            settlementDeadline,
            irysTxId
        );
    }

    /**
     * @notice Invest ETH in a specific outcome
     * @param betId The ID of the bet
     * @param outcomeIndex The index of the outcome to invest in
     */
    function invest(uint256 betId, uint256 outcomeIndex) external payable nonReentrant {
        Bet storage bet = bets[betId];
        require(bet.exists, "Bet does not exist");
        require(!bet.settled, "Bet already settled");
        require(block.timestamp < bet.investmentDeadline, "Investment deadline passed");
        require(outcomeIndex < bet.outcomes.length, "Invalid outcome index");
        require(msg.value > 0, "Investment must be greater than 0");

        OutcomePool storage pool = outcomePools[betId][outcomeIndex];

        // Track new investor
        if (pool.investments[msg.sender] == 0) {
            pool.investors.push(msg.sender);
        }

        pool.investments[msg.sender] += msg.value;
        pool.totalAmount += msg.value;

        emit InvestmentMade(betId, msg.sender, outcomeIndex, msg.value);
    }

    /**
     * @notice Settle a bet by declaring the winning outcome
     * @param betId The ID of the bet to settle
     * @param winningOutcomeIndex The index of the winning outcome
     */
    function settleBet(uint256 betId, uint256 winningOutcomeIndex) external nonReentrant {
        Bet storage bet = bets[betId];
        require(bet.exists, "Bet does not exist");
        require(msg.sender == bet.creator, "Only creator can settle");
        require(!bet.settled, "Bet already settled");
        require(block.timestamp >= bet.investmentDeadline, "Investment period not ended");
        require(winningOutcomeIndex < bet.outcomes.length, "Invalid outcome index");

        bet.settled = true;
        bet.winningOutcomeIndex = winningOutcomeIndex;

        // Calculate total pool across all outcomes
        uint256 totalPool = 0;
        for (uint256 i = 0; i < bet.outcomes.length; i++) {
            totalPool += outcomePools[betId][i].totalAmount;
        }

        // Store total pool for this bet
        betTotalPools[betId] = totalPool;

        // Calculate and store platform fee
        uint256 platformFee = (totalPool * PLATFORM_FEE_BPS) / BPS_DENOMINATOR;
        betPlatformFees[betId] = platformFee;
        accumulatedFees += platformFee;

        emit BetSettled(betId, winningOutcomeIndex, totalPool, platformFee);
    }

    /**
     * @notice Claim rewards for a settled bet
     * @param betId The ID of the bet to claim rewards from
     */
    function claimRewards(uint256 betId) external nonReentrant {
        Bet storage bet = bets[betId];
        require(bet.exists, "Bet does not exist");
        require(bet.settled, "Bet not settled yet");
        require(!hasClaimed[betId][msg.sender], "Rewards already claimed");

        OutcomePool storage winningPool = outcomePools[betId][bet.winningOutcomeIndex];
        uint256 userInvestment = winningPool.investments[msg.sender];
        require(userInvestment > 0, "No investment in winning outcome");

        hasClaimed[betId][msg.sender] = true;

        // Get stored total pool and platform fee for this bet
        uint256 totalPool = betTotalPools[betId];
        uint256 platformFee = betPlatformFees[betId];
        uint256 rewardPool = totalPool - platformFee;

        // Calculate user's share proportional to their investment
        uint256 userReward = (rewardPool * userInvestment) / winningPool.totalAmount;

        require(userReward > 0, "No rewards to claim");

        emit RewardsClaimed(betId, msg.sender, userReward);

        // Transfer rewards
        (bool success, ) = msg.sender.call{value: userReward}("");
        require(success, "Reward transfer failed");
    }

    /**
     * @notice Withdraw accumulated platform fees (owner only)
     */
    function withdrawFees() external onlyOwner nonReentrant {
        uint256 amount = accumulatedFees;
        require(amount > 0, "No fees to withdraw");

        accumulatedFees = 0;

        emit FeesWithdrawn(msg.sender, amount);

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Fee withdrawal failed");
    }

    /**
     * @notice Get bet details
     * @param betId The ID of the bet
     * @return creator The address of the bet creator
     * @return title The title of the bet
     * @return description The description of the bet
     * @return outcomes Array of outcome strings
     * @return investmentDeadline Investment deadline timestamp
     * @return settlementDeadline Settlement deadline timestamp
     * @return irysTxId Irys transaction ID
     * @return settled Whether the bet is settled
     * @return winningOutcomeIndex The winning outcome index (if settled)
     */
    function getBet(uint256 betId) external view returns (
        address creator,
        string memory title,
        string memory description,
        string[] memory outcomes,
        uint256 investmentDeadline,
        uint256 settlementDeadline,
        string memory irysTxId,
        bool settled,
        uint256 winningOutcomeIndex
    ) {
        Bet storage bet = bets[betId];
        require(bet.exists, "Bet does not exist");

        return (
            bet.creator,
            bet.title,
            bet.description,
            bet.outcomes,
            bet.investmentDeadline,
            bet.settlementDeadline,
            bet.irysTxId,
            bet.settled,
            bet.winningOutcomeIndex
        );
    }

    /**
     * @notice Get outcome pool information
     * @param betId The ID of the bet
     * @param outcomeIndex The index of the outcome
     * @return totalAmount Total amount invested in this outcome
     */
    function getOutcomePool(uint256 betId, uint256 outcomeIndex) external view returns (uint256 totalAmount) {
        require(bets[betId].exists, "Bet does not exist");
        require(outcomeIndex < bets[betId].outcomes.length, "Invalid outcome index");

        return outcomePools[betId][outcomeIndex].totalAmount;
    }

    /**
     * @notice Get user's investment in a specific outcome
     * @param betId The ID of the bet
     * @param outcomeIndex The index of the outcome
     * @param investor The address of the investor
     * @return amount The amount invested by the user
     */
    function getUserInvestment(uint256 betId, uint256 outcomeIndex, address investor) external view returns (uint256 amount) {
        require(bets[betId].exists, "Bet does not exist");
        require(outcomeIndex < bets[betId].outcomes.length, "Invalid outcome index");

        return outcomePools[betId][outcomeIndex].investments[investor];
    }

    /**
     * @notice Calculate potential rewards for a user if a specific outcome wins
     * @param betId The ID of the bet
     * @param outcomeIndex The index of the outcome
     * @param investor The address of the investor
     * @return potentialReward The potential reward amount
     */
    function calculatePotentialReward(uint256 betId, uint256 outcomeIndex, address investor) external view returns (uint256 potentialReward) {
        Bet storage bet = bets[betId];
        require(bet.exists, "Bet does not exist");
        require(outcomeIndex < bet.outcomes.length, "Invalid outcome index");

        OutcomePool storage pool = outcomePools[betId][outcomeIndex];
        uint256 userInvestment = pool.investments[investor];

        if (userInvestment == 0 || pool.totalAmount == 0) {
            return 0;
        }

        // Calculate total pool
        uint256 totalPool = 0;
        for (uint256 i = 0; i < bet.outcomes.length; i++) {
            totalPool += outcomePools[betId][i].totalAmount;
        }

        if (totalPool == 0) {
            return 0;
        }

        // Calculate platform fee
        uint256 platformFee = (totalPool * PLATFORM_FEE_BPS) / BPS_DENOMINATOR;
        uint256 rewardPool = totalPool - platformFee;

        // Calculate user's share
        potentialReward = (rewardPool * userInvestment) / pool.totalAmount;
    }

    /**
     * @notice Get all investors for a specific outcome
     * @param betId The ID of the bet
     * @param outcomeIndex The index of the outcome
     * @return investors Array of investor addresses
     */
    function getOutcomeInvestors(uint256 betId, uint256 outcomeIndex) external view returns (address[] memory investors) {
        require(bets[betId].exists, "Bet does not exist");
        require(outcomeIndex < bets[betId].outcomes.length, "Invalid outcome index");

        return outcomePools[betId][outcomeIndex].investors;
    }
}
