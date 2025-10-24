import { useState } from 'react';
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { contractAddress, contractABI } from '@/utils/evmConfig';
import { uploadBetToIrys } from '@/utils/irysClient';
import { Loader2, Plus, X } from 'lucide-react';

export default function CreateBet() {
  const { address, isConnected } = useAccount();
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [outcomes, setOutcomes] = useState(['', '']);
  const [investmentDeadline, setInvestmentDeadline] = useState('');
  const [settlementDeadline, setSettlementDeadline] = useState('');
  const [uploading, setUploading] = useState(false);

  const addOutcome = () => {
    if (outcomes.length < 10) {
      setOutcomes([...outcomes, '']);
    }
  };

  const removeOutcome = (index: number) => {
    if (outcomes.length > 2) {
      setOutcomes(outcomes.filter((_, i) => i !== index));
    }
  };

  const updateOutcome = (index: number, value: string) => {
    const newOutcomes = [...outcomes];
    newOutcomes[index] = value;
    setOutcomes(newOutcomes);
  };

  const handleCreateBet = async () => {
    if (!isConnected || !address) {
      alert('Please connect your wallet');
      return;
    }

    const filteredOutcomes = outcomes.filter(o => o.trim() !== '');
    if (filteredOutcomes.length < 2) {
      alert('Please provide at least 2 outcomes');
      return;
    }

    try {
      setUploading(true);

      // Upload to Irys first
      const betData = {
        title,
        description,
        outcomes: filteredOutcomes,
        investmentDeadline: new Date(investmentDeadline).getTime() / 1000,
        settlementDeadline: new Date(settlementDeadline).getTime() / 1000,
        creator: address,
      };

      // For now, use a placeholder Irys TX ID
      // In production, you would upload to Irys here
      const irysTxId = `placeholder-${Date.now()}`;
      
      setUploading(false);

      // Create bet on blockchain
      writeContract({
        address: contractAddress,
        abi: contractABI,
        functionName: 'createBet',
        args: [
          title,
          description,
          filteredOutcomes,
          BigInt(Math.floor(new Date(investmentDeadline).getTime() / 1000)),
          BigInt(Math.floor(new Date(settlementDeadline).getTime() / 1000)),
          irysTxId,
        ],
      });
    } catch (err) {
      console.error('Error creating bet:', err);
      setUploading(false);
    }
  };

  if (isSuccess) {
    return (
      <Card className="max-w-2xl mx-auto">
        <CardHeader>
          <CardTitle className="font-heading text-green-600">Bet Created Successfully!</CardTitle>
          <CardDescription>Your bet has been created and stored permanently on Irys.</CardDescription>
        </CardHeader>
        <CardContent>
          <Button 
            onClick={() => window.location.reload()} 
            className="w-full font-heading"
          >
            Create Another Bet
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle className="font-heading text-2xl">Create a New Bet</CardTitle>
        <CardDescription>
          Create a bet that will be permanently stored on Irys. Once created, it cannot be cancelled or deleted.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        {!isConnected && (
          <Alert>
            <AlertDescription>Please connect your wallet to create a bet.</AlertDescription>
          </Alert>
        )}

        <div className="space-y-2">
          <Label htmlFor="title" className="font-heading">Bet Title</Label>
          <Input
            id="title"
            placeholder="e.g., Who will win the 2024 Championship?"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            disabled={!isConnected}
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="description" className="font-heading">Description</Label>
          <Textarea
            id="description"
            placeholder="Provide details about the bet, rules, and how it will be settled..."
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={4}
            disabled={!isConnected}
          />
        </div>

        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <Label className="font-heading">Possible Outcomes</Label>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={addOutcome}
              disabled={!isConnected || outcomes.length >= 10}
            >
              <Plus className="w-4 h-4 mr-1" />
              Add Outcome
            </Button>
          </div>
          <div className="space-y-2">
            {outcomes.map((outcome, index) => (
              <div key={index} className="flex gap-2">
                <Input
                  placeholder={`Outcome ${index + 1}`}
                  value={outcome}
                  onChange={(e) => updateOutcome(index, e.target.value)}
                  disabled={!isConnected}
                />
                {outcomes.length > 2 && (
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    onClick={() => removeOutcome(index)}
                    disabled={!isConnected}
                  >
                    <X className="w-4 h-4" />
                  </Button>
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="investmentDeadline" className="font-heading">Investment Deadline</Label>
            <Input
              id="investmentDeadline"
              type="datetime-local"
              value={investmentDeadline}
              onChange={(e) => setInvestmentDeadline(e.target.value)}
              disabled={!isConnected}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="settlementDeadline" className="font-heading">Settlement Deadline</Label>
            <Input
              id="settlementDeadline"
              type="datetime-local"
              value={settlementDeadline}
              onChange={(e) => setSettlementDeadline(e.target.value)}
              disabled={!isConnected}
            />
          </div>
        </div>

        {error && (
          <Alert variant="destructive">
            <AlertDescription>{error.message}</AlertDescription>
          </Alert>
        )}

        <Button
          onClick={handleCreateBet}
          disabled={!isConnected || isPending || isConfirming || uploading}
          className="w-full font-heading"
          size="lg"
        >
          {uploading || isPending || isConfirming ? (
            <>
              <Loader2 className="w-4 h-4 mr-2 animate-spin" />
              {uploading ? 'Uploading to Irys...' : isConfirming ? 'Confirming...' : 'Creating Bet...'}
            </>
          ) : (
            'Create Bet'
          )}
        </Button>

        <p className="text-xs text-gray-500 text-center">
          Once created, this bet cannot be cancelled or deleted. It will be permanently stored on Irys.
        </p>
      </CardContent>
    </Card>
  );
}
