# Irys Betting Platform

A decentralized betting platform built on Ethereum Sepolia with permanent data storage on Irys/Arweave.

## Features

- 🎲 **Create Bets**: Users can create custom bets with multiple outcomes
- 💰 **Invest in Outcomes**: Invest ETH in specific bet outcomes
- 🔒 **Immutable Bets**: Bets cannot be cancelled or deleted once created
- 📦 **Permanent Storage**: Bet metadata stored permanently on Irys/Arweave
- 🏆 **Reward Distribution**: Automatic proportional reward distribution to winners
- 💳 **Wallet Integration**: Connect with MetaMask, WalletConnect, and other wallets
- ⚡ **Smart Contracts**: Secure betting logic on Ethereum Sepolia

## Tech Stack

- **Frontend**: React + TypeScript + Vite
- **Styling**: Tailwind CSS + shadcn/ui
- **Blockchain**: CodeNut Devnet (Ethereum Sepolia fork)
- **Smart Contracts**: Solidity + Foundry
- **Wallet**: RainbowKit + wagmi + viem
- **Storage**: Irys SDK (Arweave)
- **Deployment**: Vercel

## Smart Contract

- **Address**: `0xaDEa946285AE8c49d5D9696B559d5F615a99D8D7`
- **Network**: CodeNut Devnet (Chain ID: 20258)
- **RPC**: https://dev-rpc.codenut.dev
- **Platform Fee**: 2%

## Quick Start

### Prerequisites

- Node.js 18+
- pnpm 10+
- MetaMask or compatible Web3 wallet
- DevNet ETH (automatically provided)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd <project-directory>

# Install dependencies
pnpm install

# Copy environment variables
cp .env.example .env

# Start development server
pnpm dev
```

### Environment Variables

Create a `.env` file:

```env
VITE_CHAIN=devnet
VITE_WALLETCONNECT_PROJECT_ID=your_project_id
```

Get your WalletConnect Project ID from https://cloud.walletconnect.com

## Development

```bash
# Start dev server
pnpm dev

# Build for production
pnpm build

# Preview production build
pnpm preview

# Lint code
pnpm lint
```

## Smart Contract Development

```bash
cd contracts

# Install dependencies
forge install

# Run tests
forge test

# Deploy to Sepolia
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast
```

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions to Vercel.

### Quick Deploy to Vercel

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=<your-repo-url>)

1. Click the button above
2. Add environment variables:
   - `VITE_CHAIN=devnet`
   - `VITE_WALLETCONNECT_PROJECT_ID=<your-project-id>`
3. Deploy!

## How It Works

### Creating a Bet

1. Connect your wallet
2. Fill in bet details (title, description, outcomes, deadlines)
3. Bet metadata is uploaded to Irys for permanent storage
4. Smart contract creates the bet on-chain

### Investing in a Bet

1. Browse available bets
2. Select an outcome to invest in
3. Enter investment amount in ETH
4. Confirm transaction
5. Your investment is recorded on-chain

### Settling a Bet

1. Bet creator selects the winning outcome
2. Smart contract calculates reward distribution
3. 2% platform fee is deducted
4. Winners can claim their proportional rewards

## Project Structure

```
.
├── contracts/              # Smart contracts (Foundry)
│   ├── src/               # Contract source code
│   ├── test/              # Contract tests
│   ├── script/            # Deployment scripts
│   └── interfaces/        # Generated metadata
├── src/
│   ├── components/        # React components
│   ├── utils/            # Utility functions
│   ├── hooks/            # Custom React hooks
│   └── App.tsx           # Main app component
├── public/               # Static assets
└── vercel.json          # Vercel configuration
```

## License

MIT
