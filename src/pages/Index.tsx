import { useState } from 'react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import CreateBet from '@/components/CreateBet';
import BetsList from '@/components/BetsList';
import MyBets from '@/components/MyBets';

export default function Index() {
  const [activeTab, setActiveTab] = useState('browse');

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-green-50">
      {/* Header */}
      <header className="border-b bg-white/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-primary to-accent rounded-lg flex items-center justify-center">
                <span className="text-white font-heading font-bold text-xl">IB</span>
              </div>
              <div>
                <h1 className="font-heading font-bold text-2xl text-gray-900">Irys Betting</h1>
                <p className="text-xs text-gray-500">Decentralized & Permanent</p>
              </div>
            </div>
            <ConnectButton />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Hero Section */}
        <div className="text-center mb-12">
          <h2 className="font-heading font-bold text-4xl md:text-5xl text-gray-900 mb-4">
            Create & Invest in Bets
          </h2>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto leading-relaxed">
            A decentralized betting platform powered by Ethereum and Irys. Create bets, invest in outcomes, 
            and earn rewards when you predict correctly. All bet data is permanently stored on Irys.
          </p>
        </div>

        {/* Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full max-w-md mx-auto grid-cols-3 mb-8">
            <TabsTrigger value="browse" className="font-heading">Browse Bets</TabsTrigger>
            <TabsTrigger value="create" className="font-heading">Create Bet</TabsTrigger>
            <TabsTrigger value="my-bets" className="font-heading">My Bets</TabsTrigger>
          </TabsList>

          <TabsContent value="browse" className="mt-0">
            <BetsList />
          </TabsContent>

          <TabsContent value="create" className="mt-0">
            <CreateBet />
          </TabsContent>

          <TabsContent value="my-bets" className="mt-0">
            <MyBets />
          </TabsContent>
        </Tabs>
      </main>

      {/* Footer */}
      <footer className="border-t mt-16 py-8 bg-white/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center text-sm text-gray-600">
            <p className="mb-2">Powered by Ethereum Sepolia & Irys Network</p>
            <p className="text-xs text-gray-500">All bets are immutable and permanently stored</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
