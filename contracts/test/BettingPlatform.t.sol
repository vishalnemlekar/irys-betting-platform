// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import "../src/BettingPlatform.sol";

contract BettingPlatformTest is Test {
    BettingPlatform public bettingPlatform;

    address public owner;
    address public creator;
    address public user1;
    address public user2;
    address public user3;

    // Add receive function to accept ETH
    receive() external payable {}

    // Copy event declarations from BettingPlatform for testing
    event BetCreated(
        uint256 indexed betId,
        address indexed creator,
        string title,
        string[] outcomes,
        uint256 investmentDeadline,
        uint256 settlementDeadline,
        string irysTxId
    );

    event InvestmentMade(
        uint256 indexed betId,
        address indexed investor,
        uint256 outcomeIndex,
        uint256 amount
    );

    event BetSettled(
        uint256 indexed betId,
        uint256 winningOutcomeIndex,
        uint256 totalPool,
        uint256 platformFee
    );

    event RewardsClaimed(
        uint256 indexed betId,
        address indexed investor,
        uint256 amount
    );

    event FeesWithdrawn(address indexed owner, uint256 amount);

    function setUp() public {
        owner = address(this);
        creator = makeAddr("creator");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        // Deploy contract
        bettingPlatform = new BettingPlatform();

        // Fund test accounts
        vm.deal(creator, 100 ether);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
    }

    // ============ Happy Path Tests ============

    function testCreateBet() public {
        vm.startPrank(creator);

        string[] memory outcomes = new string[](3);
        outcomes[0] = "Team A wins";
        outcomes[1] = "Team B wins";
        outcomes[2] = "Draw";

        uint256 investmentDeadline = block.timestamp + 1 days;
        uint256 settlementDeadline = block.timestamp + 2 days;

        vm.expectEmit(true, true, false, true);
        emit BetCreated(
            0,
            creator,
            "Football Match",
            outcomes,
            investmentDeadline,
            settlementDeadline,
            "irys-tx-123"
        );

        uint256 betId = bettingPlatform.createBet(
            "Football Match",
            "Match between Team A and Team B",
            outcomes,
            investmentDeadline,
            settlementDeadline,
            "irys-tx-123"
        );

        assertEq(betId, 0, "First bet ID should be 0");

        (
            address betCreator,
            string memory title,
            string memory description,
            string[] memory betOutcomes,
            uint256 invDeadline,
            uint256 settDeadline,
            string memory irysTxId,
            bool settled,

        ) = bettingPlatform.getBet(betId);

        assertEq(betCreator, creator, "Creator should match");
        assertEq(title, "Football Match", "Title should match");
        assertEq(description, "Match between Team A and Team B", "Description should match");
        assertEq(betOutcomes.length, 3, "Should have 3 outcomes");
        assertEq(invDeadline, investmentDeadline, "Investment deadline should match");
        assertEq(settDeadline, settlementDeadline, "Settlement deadline should match");
        assertEq(irysTxId, "irys-tx-123", "Irys TX ID should match");
        assertFalse(settled, "Bet should not be settled");

        vm.stopPrank();
    }

    function testInvest() public {
        uint256 betId = _createSampleBet();

        vm.startPrank(user1);

        vm.expectEmit(true, true, false, true);
        emit InvestmentMade(betId, user1, 0, 1 ether);

        bettingPlatform.invest{value: 1 ether}(betId, 0);

        uint256 investment = bettingPlatform.getUserInvestment(betId, 0, user1);
        assertEq(investment, 1 ether, "Investment should be recorded");

        uint256 poolTotal = bettingPlatform.getOutcomePool(betId, 0);
        assertEq(poolTotal, 1 ether, "Pool total should match");

        vm.stopPrank();
    }

    function testMultipleInvestments() public {
        uint256 betId = _createSampleBet();

        // User1 invests in outcome 0
        vm.prank(user1);
        bettingPlatform.invest{value: 2 ether}(betId, 0);

        // User2 invests in outcome 1
        vm.prank(user2);
        bettingPlatform.invest{value: 3 ether}(betId, 1);

        // User3 invests in outcome 0
        vm.prank(user3);
        bettingPlatform.invest{value: 1 ether}(betId, 0);

        assertEq(bettingPlatform.getOutcomePool(betId, 0), 3 ether, "Outcome 0 pool should be 3 ETH");
        assertEq(bettingPlatform.getOutcomePool(betId, 1), 3 ether, "Outcome 1 pool should be 3 ETH");
        assertEq(bettingPlatform.getUserInvestment(betId, 0, user1), 2 ether, "User1 investment should be 2 ETH");
        assertEq(bettingPlatform.getUserInvestment(betId, 1, user2), 3 ether, "User2 investment should be 3 ETH");
    }

    function testSettleBet() public {
        uint256 betId = _createSampleBet();

        // Users invest
        vm.prank(user1);
        bettingPlatform.invest{value: 2 ether}(betId, 0);

        vm.prank(user2);
        bettingPlatform.invest{value: 3 ether}(betId, 1);

        // Move past investment deadline
        vm.warp(block.timestamp + 1 days + 1);

        vm.startPrank(creator);

        uint256 totalPool = 5 ether;
        uint256 platformFee = (totalPool * 200) / 10000; // 2%

        vm.expectEmit(true, false, false, true);
        emit BetSettled(betId, 0, totalPool, platformFee);

        bettingPlatform.settleBet(betId, 0);

        (, , , , , , , bool settled, uint256 winningOutcome) = bettingPlatform.getBet(betId);
        assertTrue(settled, "Bet should be settled");
        assertEq(winningOutcome, 0, "Winning outcome should be 0");

        vm.stopPrank();
    }

    function testClaimRewards() public {
        uint256 betId = _createSampleBet();

        // User1 invests 2 ETH in outcome 0
        vm.prank(user1);
        bettingPlatform.invest{value: 2 ether}(betId, 0);

        // User2 invests 3 ETH in outcome 1
        vm.prank(user2);
        bettingPlatform.invest{value: 3 ether}(betId, 1);

        // Move past investment deadline and settle
        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(creator);
        bettingPlatform.settleBet(betId, 0); // User1 wins

        // Calculate expected reward
        uint256 totalPool = 5 ether;
        uint256 platformFee = (totalPool * 200) / 10000; // 0.1 ETH
        uint256 rewardPool = totalPool - platformFee; // 4.9 ETH
        uint256 expectedReward = rewardPool; // User1 gets all since they're the only winner

        uint256 balanceBefore = user1.balance;

        vm.startPrank(user1);

        vm.expectEmit(true, true, false, true);
        emit RewardsClaimed(betId, user1, expectedReward);

        bettingPlatform.claimRewards(betId);

        uint256 balanceAfter = user1.balance;
        assertEq(balanceAfter - balanceBefore, expectedReward, "User should receive correct reward");

        vm.stopPrank();
    }

    function testWithdrawFees() public {
        uint256 betId = _createSampleBet();

        // Users invest
        vm.prank(user1);
        bettingPlatform.invest{value: 2 ether}(betId, 0);

        vm.prank(user2);
        bettingPlatform.invest{value: 3 ether}(betId, 1);

        // Settle bet
        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(creator);
        bettingPlatform.settleBet(betId, 0);

        uint256 expectedFees = (5 ether * 200) / 10000; // 0.1 ETH
        assertEq(bettingPlatform.accumulatedFees(), expectedFees, "Accumulated fees should match after settlement");

        // Verify contract has full balance before any claims
        assertEq(address(bettingPlatform).balance, 5 ether, "Contract should have full balance");

        uint256 balanceBefore = owner.balance;

        vm.expectEmit(true, false, false, true);
        emit FeesWithdrawn(owner, expectedFees);

        bettingPlatform.withdrawFees();

        uint256 balanceAfter = owner.balance;
        assertEq(balanceAfter - balanceBefore, expectedFees, "Owner should receive fees");
        assertEq(bettingPlatform.accumulatedFees(), 0, "Accumulated fees should be reset");
        
        // After fee withdrawal, contract should have 4.9 ETH left for rewards
        assertEq(address(bettingPlatform).balance, 5 ether - expectedFees, "Contract should have reward pool left");
    }

    // ============ Access Control Tests ============

    function testOnlyCreatorCanSettle() public {
        uint256 betId = _createSampleBet();

        vm.warp(block.timestamp + 1 days + 1);

        vm.prank(user1);
        vm.expectRevert("Only creator can settle");
        bettingPlatform.settleBet(betId, 0);
    }

    function testOnlyOwnerCanWithdrawFees() public {
        uint256 betId = _createSampleBet();

        vm.prank(user1);
        bettingPlatform.invest{value: 1 ether}(betId, 0);

        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(creator);
        bettingPlatform.settleBet(betId, 0);

        vm.prank(user1);
        vm.expectRevert();
        bettingPlatform.withdrawFees();
    }

    // ============ Edge Case Tests ============

    function testCreateBetWithMinimumOutcomes() public {
        vm.startPrank(creator);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        uint256 betId = bettingPlatform.createBet(
            "Simple Bet",
            "Yes or No",
            outcomes,
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "irys-tx-456"
        );

        (, , , string[] memory betOutcomes, , , , , ) = bettingPlatform.getBet(betId);
        assertEq(betOutcomes.length, 2, "Should have 2 outcomes");

        vm.stopPrank();
    }

    function testInvestMultipleTimes() public {
        uint256 betId = _createSampleBet();

        vm.startPrank(user1);

        bettingPlatform.invest{value: 1 ether}(betId, 0);
        bettingPlatform.invest{value: 2 ether}(betId, 0);

        uint256 totalInvestment = bettingPlatform.getUserInvestment(betId, 0, user1);
        assertEq(totalInvestment, 3 ether, "Total investment should be 3 ETH");

        vm.stopPrank();
    }

    function testCalculatePotentialReward() public {
        uint256 betId = _createSampleBet();

        vm.prank(user1);
        bettingPlatform.invest{value: 2 ether}(betId, 0);

        vm.prank(user2);
        bettingPlatform.invest{value: 3 ether}(betId, 1);

        // Calculate potential reward if outcome 0 wins
        uint256 potentialReward = bettingPlatform.calculatePotentialReward(betId, 0, user1);

        uint256 totalPool = 5 ether;
        uint256 platformFee = (totalPool * 200) / 10000;
        uint256 expectedReward = totalPool - platformFee;

        assertEq(potentialReward, expectedReward, "Potential reward should match calculation");
    }

    function testGetOutcomeInvestors() public {
        uint256 betId = _createSampleBet();

        vm.prank(user1);
        bettingPlatform.invest{value: 1 ether}(betId, 0);

        vm.prank(user2);
        bettingPlatform.invest{value: 2 ether}(betId, 0);

        address[] memory investors = bettingPlatform.getOutcomeInvestors(betId, 0);
        assertEq(investors.length, 2, "Should have 2 investors");
        assertEq(investors[0], user1, "First investor should be user1");
        assertEq(investors[1], user2, "Second investor should be user2");
    }

    // ============ Revert Tests ============

    function testRevertCreateBetEmptyTitle() public {
        vm.startPrank(creator);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        vm.expectRevert("Title cannot be empty");
        bettingPlatform.createBet(
            "",
            "Description",
            outcomes,
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "irys-tx-123"
        );

        vm.stopPrank();
    }

    function testRevertCreateBetInsufficientOutcomes() public {
        vm.startPrank(creator);

        string[] memory outcomes = new string[](1);
        outcomes[0] = "Only one";

        vm.expectRevert("At least 2 outcomes required");
        bettingPlatform.createBet(
            "Title",
            "Description",
            outcomes,
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "irys-tx-123"
        );

        vm.stopPrank();
    }

    function testRevertCreateBetInvalidDeadlines() public {
        vm.startPrank(creator);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        vm.expectRevert("Investment deadline must be in future");
        bettingPlatform.createBet(
            "Title",
            "Description",
            outcomes,
            block.timestamp - 1,
            block.timestamp + 2 days,
            "irys-tx-123"
        );

        vm.stopPrank();
    }

    function testRevertCreateBetSettlementBeforeInvestment() public {
        vm.startPrank(creator);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        vm.expectRevert("Settlement deadline must be after investment deadline");
        bettingPlatform.createBet(
            "Title",
            "Description",
            outcomes,
            block.timestamp + 2 days,
            block.timestamp + 1 days,
            "irys-tx-123"
        );

        vm.stopPrank();
    }

    function testRevertCreateBetEmptyIrysTxId() public {
        vm.startPrank(creator);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        vm.expectRevert("Irys TX ID cannot be empty");
        bettingPlatform.createBet(
            "Title",
            "Description",
            outcomes,
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            ""
        );

        vm.stopPrank();
    }

    function testRevertInvestNonexistentBet() public {
        vm.prank(user1);
        vm.expectRevert("Bet does not exist");
        bettingPlatform.invest{value: 1 ether}(999, 0);
    }

    function testRevertInvestAfterDeadline() public {
        uint256 betId = _createSampleBet();

        vm.warp(block.timestamp + 1 days + 1);

        vm.prank(user1);
        vm.expectRevert("Investment deadline passed");
        bettingPlatform.invest{value: 1 ether}(betId, 0);
    }

    function testRevertInvestInSettledBet() public {
        uint256 betId = _createSampleBet();

        // Add some investment first
        vm.prank(user1);
        bettingPlatform.invest{value: 1 ether}(betId, 0);

        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(creator);
        bettingPlatform.settleBet(betId, 0);

        // Now try to invest after settlement
        vm.prank(user2);
        vm.expectRevert("Bet already settled");
        bettingPlatform.invest{value: 1 ether}(betId, 0);
    }

    function testRevertInvestInvalidOutcome() public {
        uint256 betId = _createSampleBet();

        vm.prank(user1);
        vm.expectRevert("Invalid outcome index");
        bettingPlatform.invest{value: 1 ether}(betId, 99);
    }

    function testRevertInvestZeroAmount() public {
        uint256 betId = _createSampleBet();

        vm.prank(user1);
        vm.expectRevert("Investment must be greater than 0");
        bettingPlatform.invest{value: 0}(betId, 0);
    }

    function testRevertSettleNonexistentBet() public {
        vm.prank(creator);
        vm.expectRevert("Bet does not exist");
        bettingPlatform.settleBet(999, 0);
    }

    function testRevertSettleBeforeInvestmentDeadline() public {
        uint256 betId = _createSampleBet();

        vm.prank(creator);
        vm.expectRevert("Investment period not ended");
        bettingPlatform.settleBet(betId, 0);
    }

    function testRevertSettleAlreadySettled() public {
        uint256 betId = _createSampleBet();

        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(creator);
        bettingPlatform.settleBet(betId, 0);

        vm.prank(creator);
        vm.expectRevert("Bet already settled");
        bettingPlatform.settleBet(betId, 0);
    }

    function testRevertSettleInvalidOutcome() public {
        uint256 betId = _createSampleBet();

        vm.warp(block.timestamp + 1 days + 1);

        vm.prank(creator);
        vm.expectRevert("Invalid outcome index");
        bettingPlatform.settleBet(betId, 99);
    }

    function testRevertClaimNonexistentBet() public {
        vm.prank(user1);
        vm.expectRevert("Bet does not exist");
        bettingPlatform.claimRewards(999);
    }

    function testRevertClaimUnsettledBet() public {
        uint256 betId = _createSampleBet();

        vm.prank(user1);
        bettingPlatform.invest{value: 1 ether}(betId, 0);

        vm.prank(user1);
        vm.expectRevert("Bet not settled yet");
        bettingPlatform.claimRewards(betId);
    }

    function testRevertClaimAlreadyClaimed() public {
        uint256 betId = _createSampleBet();

        vm.prank(user1);
        bettingPlatform.invest{value: 1 ether}(betId, 0);

        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(creator);
        bettingPlatform.settleBet(betId, 0);

        vm.prank(user1);
        bettingPlatform.claimRewards(betId);

        vm.prank(user1);
        vm.expectRevert("Rewards already claimed");
        bettingPlatform.claimRewards(betId);
    }

    function testRevertClaimNoInvestment() public {
        uint256 betId = _createSampleBet();

        vm.prank(user1);
        bettingPlatform.invest{value: 1 ether}(betId, 0);

        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(creator);
        bettingPlatform.settleBet(betId, 0);

        vm.prank(user2);
        vm.expectRevert("No investment in winning outcome");
        bettingPlatform.claimRewards(betId);
    }

    function testRevertWithdrawFeesNoFees() public {
        vm.expectRevert("No fees to withdraw");
        bettingPlatform.withdrawFees();
    }

    function testRevertGetNonexistentBet() public {
        vm.expectRevert("Bet does not exist");
        bettingPlatform.getBet(999);
    }

    function testRevertGetOutcomePoolNonexistentBet() public {
        vm.expectRevert("Bet does not exist");
        bettingPlatform.getOutcomePool(999, 0);
    }

    function testRevertGetOutcomePoolInvalidOutcome() public {
        uint256 betId = _createSampleBet();

        vm.expectRevert("Invalid outcome index");
        bettingPlatform.getOutcomePool(betId, 99);
    }

    // ============ State Transition Tests ============

    function testBetLifecycle() public {
        // Create bet
        uint256 betId = _createSampleBet();

        // Invest phase
        vm.prank(user1);
        bettingPlatform.invest{value: 2 ether}(betId, 0);

        vm.prank(user2);
        bettingPlatform.invest{value: 3 ether}(betId, 1);

        // Verify investment phase state
        assertEq(bettingPlatform.getOutcomePool(betId, 0), 2 ether, "Outcome 0 pool should be 2 ETH");
        assertEq(bettingPlatform.getOutcomePool(betId, 1), 3 ether, "Outcome 1 pool should be 3 ETH");

        // Settlement phase
        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(creator);
        bettingPlatform.settleBet(betId, 0);

        // Verify settlement state
        (, , , , , , , bool settled, uint256 winningOutcome) = bettingPlatform.getBet(betId);
        assertTrue(settled, "Bet should be settled");
        assertEq(winningOutcome, 0, "Winning outcome should be 0");

        // Claim phase
        uint256 balanceBefore = user1.balance;
        vm.prank(user1);
        bettingPlatform.claimRewards(betId);

        assertTrue(user1.balance > balanceBefore, "User1 should receive rewards");
        assertTrue(bettingPlatform.hasClaimed(betId, user1), "User1 should be marked as claimed");
    }

    function testMultipleBetsIndependence() public {
        // Create two bets
        uint256 betId1 = _createSampleBet();

        vm.prank(creator);
        string[] memory outcomes2 = new string[](2);
        outcomes2[0] = "Option A";
        outcomes2[1] = "Option B";
        uint256 betId2 = bettingPlatform.createBet(
            "Second Bet",
            "Another bet",
            outcomes2,
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "irys-tx-456"
        );

        // Invest in both
        vm.prank(user1);
        bettingPlatform.invest{value: 1 ether}(betId1, 0);

        vm.prank(user1);
        bettingPlatform.invest{value: 2 ether}(betId2, 0);

        // Verify independence
        assertEq(bettingPlatform.getUserInvestment(betId1, 0, user1), 1 ether, "Bet 1 investment should be 1 ETH");
        assertEq(bettingPlatform.getUserInvestment(betId2, 0, user1), 2 ether, "Bet 2 investment should be 2 ETH");
    }

    // ============ Fuzz Tests ============

    function testFuzzInvest(uint256 amount) public {
        amount = bound(amount, 0.01 ether, 100 ether);

        uint256 betId = _createSampleBet();

        vm.deal(user1, amount);
        vm.prank(user1);
        bettingPlatform.invest{value: amount}(betId, 0);

        assertEq(bettingPlatform.getUserInvestment(betId, 0, user1), amount, "Investment should match");
        assertEq(bettingPlatform.getOutcomePool(betId, 0), amount, "Pool should match");
    }

    function testFuzzMultipleInvestors(uint8 numInvestors) public {
        numInvestors = uint8(bound(numInvestors, 2, 20));

        uint256 betId = _createSampleBet();

        uint256 totalPool = 0;
        for (uint256 i = 0; i < numInvestors; i++) {
            address investor = address(uint160(i + 1000));
            vm.deal(investor, 10 ether);

            vm.prank(investor);
            bettingPlatform.invest{value: 1 ether}(betId, 0);

            totalPool += 1 ether;
        }

        assertEq(bettingPlatform.getOutcomePool(betId, 0), totalPool, "Total pool should match");
    }

    function testFuzzRewardCalculation(uint256 investment1, uint256 investment2) public {
        investment1 = bound(investment1, 0.1 ether, 50 ether);
        investment2 = bound(investment2, 0.1 ether, 50 ether);

        uint256 betId = _createSampleBet();

        vm.deal(user1, investment1);
        vm.prank(user1);
        bettingPlatform.invest{value: investment1}(betId, 0);

        vm.deal(user2, investment2);
        vm.prank(user2);
        bettingPlatform.invest{value: investment2}(betId, 1);

        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(creator);
        bettingPlatform.settleBet(betId, 0);

        uint256 totalPool = investment1 + investment2;
        uint256 platformFee = (totalPool * 200) / 10000;
        uint256 expectedReward = totalPool - platformFee;

        uint256 balanceBefore = user1.balance;
        vm.prank(user1);
        bettingPlatform.claimRewards(betId);

        assertEq(user1.balance - balanceBefore, expectedReward, "Reward should match calculation");
    }

    // ============ Helper Functions ============

    function _createSampleBet() internal returns (uint256) {
        vm.startPrank(creator);

        string[] memory outcomes = new string[](3);
        outcomes[0] = "Team A wins";
        outcomes[1] = "Team B wins";
        outcomes[2] = "Draw";

        uint256 betId = bettingPlatform.createBet(
            "Football Match",
            "Match between Team A and Team B",
            outcomes,
            block.timestamp + 1 days,
            block.timestamp + 2 days,
            "irys-tx-123"
        );

        vm.stopPrank();
        return betId;
    }
}
