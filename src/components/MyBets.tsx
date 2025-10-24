import { useState } from 'react';
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { formatEther } from 'viem';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { contractAddress, contractABI } from '@/utils/evmConfig';
import { format } from 'date-fns';
import { Loader2, Trophy, Wallet } from 'lucide-react';

export default function MyBets() {
  const { address, isConnected } = useAccount();

  const { data: nextBetId } = useReadContract({
    address: contractAddress,
    abi: contractABI,
    functionName: 'nextBetId',
  });

  const totalBets = nextBetId ? Number(nextBetId) : 0;

  if (!isConnected) {
    return (
      <Card>
        <CardContent className="py-12 text-center">
          <Wallet className="w-12 h-12 mx-auto text-gray-400 mb-4" />
          <h3 className="font-heading font-semibold text-xl mb-2">Connect Your Wallet</h3>
          <p className="text-gray-600">Connect your wallet to view your bets and investments.</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      <div className="grid gap-6">
        {totalBets === 0 ? (
          <Card>
            <CardContent className="py-12 text-center">
              <Trophy className="w-12 h-12 mx-auto text-gray-400 mb-4" />
              <h3 className="font-heading font-semibold text-xl mb-2">No Bets Yet</h3>
              <p className="text-gray-600">You haven't created or invested in any bets yet.</p>
            </CardContent>
          </Card>
        ) : (
          Array.from({ length: totalBets }, (_, i) => (
            <MyBetCard key={i} betId={i} userAddress={address!} />
          ))
        )}
      </div>
    </div>
  );
}

function MyBetCard({ betId, userAddress }: { betId: number; userAddress: string }) {
  const [selectedWinner, setSelectedWinner] = useState<string>('');

  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isSettleSuccess } = useWaitForTransactionReceipt({ hash });

  const { data: betData } = useReadContract({
    address: contractAddress,
    abi: contractABI,
    functionName: 'getBet',
    args: [BigInt(betId)],
  });

  const { writeContract: claimWrite, data: claimHash, isPending: isClaimPending } = useWriteContract();
  const { isLoading: isClaimConfirming, isSuccess: isClaimSuccess } = useWaitForTransactionReceipt({ 
    hash: claimHash 
  });

  if (!betData) return null;

  const [
    creator,
    title,
    description,
    outcomes,
    investmentDeadline,
    settlementDeadline,
    irysTxId,
    settled,
    winningOutcomeIndex,
  ] = betData as any;

  const isCreator = creator.toLowerCase() === userAddress.toLowerCase();
  const now = Math.floor(Date.now() / 1000);
  const canSettle = isCreator && !settled && now >= Number(investmentDeadline);

  const handleSettle = () => {
    if (!selectedWinner) return;

    writeContract({
      address: contractAddress,
      abi: contractABI,
      functionName: 'settleBet',
      args: [BigInt(betId), BigInt(selectedWinner)],
    });
  };

  const handleClaim = () => {
    claimWrite({
      address: contractAddress,
      abi: contractABI,
      functionName: 'claimRewards',
      args: [BigInt(betId)],
    });
  };

  if (isSettleSuccess || isClaimSuccess) {
    setTimeout(() => {
      window.location.reload();
    }, 2000);
  }

  // Check if user has any investments in this bet
  const hasInvestments = true; // We'll show all bets for simplicity

  if (!isCreator && !hasInvestments) return null;

  return (
    <Card>
      <CardHeader className="bg-gradient-to-r from-purple-50 to-green-50">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <CardTitle className="font-heading text-xl mb-2">{title}</CardTitle>
            <CardDescription className="text-sm">{description}</CardDescription>
          </div>
          <div className="flex flex-col gap-2">
            {isCreator && <Badge variant="secondary" className="font-heading">Creator</Badge>}
            {settled ? (
              <Badge className="font-heading bg-green-600">Settled</Badge>
            ) : (
              <Badge variant="outline" className="font-heading">Active</Badge>
            )}
          </div>
        </div>
      </CardHeader>

      <CardContent className="pt-6 space-y-4">
        {/* Outcomes with pools */}
        <div className="space-y-2">
          <h4 className="font-heading font-semibold text-sm">Outcomes</h4>
          {outcomes.map((outcome: string, index: number) => (
            <OutcomeInfo
              key={index}
              betId={betId}
              outcomeIndex={index}
              outcomeName={outcome}
              isWinner={settled && Number(winningOutcomeIndex) === index}
              userAddress={userAddress}
            />
          ))}
        </div>

        {/* Settlement Section for Creator */}
        {canSettle && (
          <div className="border-t pt-4 space-y-3">
            <h4 className="font-heading font-semibold">Settle Bet</h4>
            <Select value={selectedWinner} onValueChange={setSelectedWinner}>
              <SelectTrigger>
                <SelectValue placeholder="Select winning outcome" />
              </SelectTrigger>
              <SelectContent>
                {outcomes.map((outcome: string, index: number) => (
                  <SelectItem key={index} value={index.toString()}>
                    {outcome}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {error && (
              <Alert variant="destructive">
                <AlertDescription className="text-xs">{error.message}</AlertDescription>
              </Alert>
            )}

            <Button
              onClick={handleSettle}
              disabled={!selectedWinner || isPending || isConfirming}
              className="w-full font-heading"
            >
              {isPending || isConfirming ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  {isConfirming ? 'Confirming...' : 'Settling...'}
                </>
              ) : (
                'Settle Bet'
              )}
            </Button>
          </div>
        )}

        {/* Claim Rewards Section */}
        {settled && (
          <div className="border-t pt-4">
            <Button
              onClick={handleClaim}
              disabled={isClaimPending || isClaimConfirming}
              className="w-full font-heading"
              variant="default"
            >
              {isClaimPending || isClaimConfirming ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  {isClaimConfirming ? 'Confirming...' : 'Claiming...'}
                </>
              ) : (
                <>
                  <Trophy className="w-4 h-4 mr-2" />
                  Claim Rewards
                </>
              )}
            </Button>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

function OutcomeInfo({
  betId,
  outcomeIndex,
  outcomeName,
  isWinner,
  userAddress,
}: any) {
  const { data: poolData } = useReadContract({
    address: contractAddress,
    abi: contractABI,
    functionName: 'getOutcomePool',
    args: [BigInt(betId), BigInt(outcomeIndex)],
  });

  const { data: userInvestment } = useReadContract({
    address: contractAddress,
    abi: contractABI,
    functionName: 'getUserInvestment',
    args: [BigInt(betId), BigInt(outcomeIndex), userAddress],
  });

  const pool = poolData ? formatEther(poolData as bigint) : '0';
  const investment = userInvestment ? formatEther(userInvestment as bigint) : '0';

  return (
    <div
      className={`border rounded-lg p-3 ${
        isWinner ? 'bg-green-50 border-green-500' : 'border-gray-200'
      }`}
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="font-medium">{outcomeName}</span>
          {isWinner && <Badge className="bg-green-600 text-xs">Winner</Badge>}
        </div>
        <div className="text-right">
          <p className="text-sm font-semibold">{parseFloat(pool).toFixed(4)} ETH</p>
          {parseFloat(investment) > 0 && (
            <p className="text-xs text-gray-600">Your investment: {parseFloat(investment).toFixed(4)} ETH</p>
          )}
        </div>
      </div>
    </div>
  );
}
