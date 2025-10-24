import { useState, useEffect } from 'react';
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { formatEther, parseEther } from 'viem';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { contractAddress, contractABI } from '@/utils/evmConfig';
import { format } from 'date-fns';
import { Loader2, TrendingUp, Clock, Users } from 'lucide-react';

interface Bet {
  id: number;
  creator: string;
  title: string;
  description: string;
  outcomes: string[];
  investmentDeadline: bigint;
  settlementDeadline: bigint;
  irysTxId: string;
  settled: boolean;
  winningOutcomeIndex: bigint;
}

export default function BetsList() {
  const { address, isConnected } = useAccount();
  const [selectedBet, setSelectedBet] = useState<number | null>(null);
  const [selectedOutcome, setSelectedOutcome] = useState<number>(0);
  const [investAmount, setInvestAmount] = useState('');

  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  // Read next bet ID to know how many bets exist
  const { data: nextBetId } = useReadContract({
    address: contractAddress,
    abi: contractABI,
    functionName: 'nextBetId',
  });

  const totalBets = nextBetId ? Number(nextBetId) : 0;

  const handleInvest = () => {
    if (!isConnected || selectedBet === null) return;

    writeContract({
      address: contractAddress,
      abi: contractABI,
      functionName: 'invest',
      args: [BigInt(selectedBet), BigInt(selectedOutcome)],
      value: parseEther(investAmount),
    });
  };

  if (isSuccess) {
    setTimeout(() => {
      window.location.reload();
    }, 2000);
  }

  return (
    <div className="space-y-6">
      {totalBets === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <TrendingUp className="w-12 h-12 mx-auto text-gray-400 mb-4" />
            <h3 className="font-heading font-semibold text-xl mb-2">No Bets Yet</h3>
            <p className="text-gray-600 mb-4">Be the first to create a bet!</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6">
          {Array.from({ length: totalBets }, (_, i) => (
            <BetCard
              key={i}
              betId={i}
              onInvest={(outcomeIndex) => {
                setSelectedBet(i);
                setSelectedOutcome(outcomeIndex);
              }}
              selectedBet={selectedBet}
              selectedOutcome={selectedOutcome}
              investAmount={investAmount}
              setInvestAmount={setInvestAmount}
              handleInvest={handleInvest}
              isPending={isPending}
              isConfirming={isConfirming}
              error={error}
            />
          ))}
        </div>
      )}
    </div>
  );
}

function BetCard({
  betId,
  onInvest,
  selectedBet,
  selectedOutcome,
  investAmount,
  setInvestAmount,
  handleInvest,
  isPending,
  isConfirming,
  error,
}: any) {
  const { address, isConnected } = useAccount();

  const { data: betData } = useReadContract({
    address: contractAddress,
    abi: contractABI,
    functionName: 'getBet',
    args: [BigInt(betId)],
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

  const now = Math.floor(Date.now() / 1000);
  const investmentDeadlineSec = Number(investmentDeadline);
  const settlementDeadlineSec = Number(settlementDeadline);
  const canInvest = now < investmentDeadlineSec && !settled;

  return (
    <Card className="overflow-hidden">
      <CardHeader className="bg-gradient-to-r from-purple-50 to-green-50">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <CardTitle className="font-heading text-xl mb-2">{title}</CardTitle>
            <CardDescription className="text-sm">{description}</CardDescription>
          </div>
          {settled ? (
            <Badge variant="secondary" className="font-heading">Settled</Badge>
          ) : canInvest ? (
            <Badge className="font-heading bg-green-600">Open</Badge>
          ) : (
            <Badge variant="outline" className="font-heading">Closed</Badge>
          )}
        </div>
      </CardHeader>

      <CardContent className="pt-6 space-y-4">
        {/* Deadlines */}
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4 text-gray-500" />
            <div>
              <p className="text-xs text-gray-500">Investment Deadline</p>
              <p className="font-medium">{format(investmentDeadlineSec * 1000, 'MMM dd, yyyy HH:mm')}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4 text-gray-500" />
            <div>
              <p className="text-xs text-gray-500">Settlement Deadline</p>
              <p className="font-medium">{format(settlementDeadlineSec * 1000, 'MMM dd, yyyy HH:mm')}</p>
            </div>
          </div>
        </div>

        {/* Outcomes */}
        <div className="space-y-3">
          <h4 className="font-heading font-semibold text-sm">Outcomes</h4>
          <div className="space-y-2">
            {outcomes.map((outcome: string, index: number) => (
              <OutcomeCard
                key={index}
                betId={betId}
                outcomeIndex={index}
                outcomeName={outcome}
                isWinner={settled && Number(winningOutcomeIndex) === index}
                canInvest={canInvest}
                onInvest={() => onInvest(index)}
                isSelected={selectedBet === betId && selectedOutcome === index}
              />
            ))}
          </div>
        </div>

        {/* Investment Form */}
        {selectedBet === betId && canInvest && isConnected && (
          <div className="border-t pt-4 space-y-3">
            <div className="space-y-2">
              <label className="text-sm font-medium">Investment Amount (ETH)</label>
              <Input
                type="number"
                step="0.01"
                placeholder="0.1"
                value={investAmount}
                onChange={(e) => setInvestAmount(e.target.value)}
              />
            </div>

            {error && (
              <Alert variant="destructive">
                <AlertDescription className="text-xs">{error.message}</AlertDescription>
              </Alert>
            )}

            <Button
              onClick={handleInvest}
              disabled={isPending || isConfirming || !investAmount}
              className="w-full font-heading"
            >
              {isPending || isConfirming ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  {isConfirming ? 'Confirming...' : 'Investing...'}
                </>
              ) : (
                'Confirm Investment'
              )}
            </Button>
          </div>
        )}

        {!isConnected && canInvest && (
          <Alert>
            <AlertDescription className="text-xs">Connect your wallet to invest in this bet.</AlertDescription>
          </Alert>
        )}
      </CardContent>
    </Card>
  );
}

function OutcomeCard({
  betId,
  outcomeIndex,
  outcomeName,
  isWinner,
  canInvest,
  onInvest,
  isSelected,
}: any) {
  const { data: poolData } = useReadContract({
    address: contractAddress,
    abi: contractABI,
    functionName: 'getOutcomePool',
    args: [BigInt(betId), BigInt(outcomeIndex)],
  });

  const pool = poolData ? formatEther(poolData as bigint) : '0';

  return (
    <div
      className={`border rounded-lg p-3 transition-all ${
        isSelected ? 'border-primary bg-primary/5' : 'border-gray-200'
      } ${isWinner ? 'bg-green-50 border-green-500' : ''}`}
    >
      <div className="flex items-center justify-between mb-2">
        <div className="flex items-center gap-2">
          <span className="font-medium">{outcomeName}</span>
          {isWinner && <Badge className="bg-green-600 text-xs">Winner</Badge>}
        </div>
        <span className="text-sm font-semibold">{parseFloat(pool).toFixed(4)} ETH</span>
      </div>

      {canInvest && (
        <Button
          variant={isSelected ? 'default' : 'outline'}
          size="sm"
          onClick={onInvest}
          className="w-full font-heading"
        >
          {isSelected ? 'Selected' : 'Invest in this outcome'}
        </Button>
      )}
    </div>
  );
}
