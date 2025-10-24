# Complete Irys Betting Platform Setup Guide

This guide contains all the files and instructions needed to recreate the entire project from scratch.

## Quick Start

1. Create a new directory and initialize the project:
```bash
mkdir irys-betting-platform
cd irys-betting-platform
npm init -y
```

2. Copy all files from the sections below
3. Run `pnpm install`
4. Run `pnpm dev`

## Project Structure

```
irys-betting-platform/
├── src/
│   ├── components/
│   │   ├── ui/              # shadcn/ui components (40+ files)
│   │   ├── CreateBet.tsx
│   │   ├── BetsList.tsx
│   │   ├── MyBets.tsx
│   │   ├── error-overlay.tsx
│   │   └── with-error-overlay.tsx
│   ├── utils/
│   │   ├── evmConfig.ts
│   │   ├── irysClient.ts
│   │   └── wagmiConfig.ts
│   ├── hooks/
│   │   ├── use-mobile.tsx
│   │   └── use-toast.ts
│   ├── lib/
│   │   └── utils.ts
│   ├── pages/
│   │   ├── Index.tsx
│   │   └── Placeholder.tsx
│   ├── assets/
│   │   └── react.svg
│   ├── App.tsx
│   ├── main.tsx
│   ├── index.css
│   ├── metadata.json
│   └── vite-env.d.ts
├── contracts/
│   ├── src/
│   │   ├── BettingPlatform.sol
│   │   └── TemporaryDeployFactory.sol
│   ├── test/
│   │   └── BettingPlatform.t.sol
│   ├── script/
│   │   └── Deploy.s.sol
│   ├── interfaces/
│   │   ├── metadata.json
│   │   └── deploy.json
│   ├── foundry.toml
│   ├── remappings.txt
│   └── package.json
├── plugins/
│   └── component-tagger.ts
├── public/
│   └── favicon.ico
├── Configuration Files
│   ├── .env
│   ├── .env.example
│   ├── .gitignore
│   ├── package.json
│   ├── pnpm-lock.yaml
│   ├── tsconfig.json
│   ├── tsconfig.app.json
│   ├── tsconfig.node.json
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   ├── eslint.config.js
│   ├── components.json
│   ├── vercel.json
│   └── index.html
└── Documentation
    ├── README.md
    ├── DEPLOYMENT.md
    └── .cprules

```

## Essential Files to Copy

### Root Configuration Files

1. **package.json** - See file in project root
2. **vercel.json** - See file in project root
3. **.env.example** - See file in project root
4. **.gitignore** - See file in project root
5. **tsconfig.json** - See file in project root
6. **vite.config.ts** - See file in project root
7. **tailwind.config.js** - See file in project root
8. **index.html** - See file in project root

### Source Files (src/)

**Main Application Files:**
- `src/main.tsx` - React entry point
- `src/App.tsx` - Main app component with routing
- `src/index.css` - Global styles

**Components:**
- `src/components/CreateBet.tsx` - Bet creation form
- `src/components/BetsList.tsx` - Browse and invest in bets
- `src/components/MyBets.tsx` - User's bets management

**Utils:**
- `src/utils/evmConfig.ts` - EVM chain configuration
- `src/utils/irysClient.ts` - Irys SDK initialization
- `src/utils/wagmiConfig.ts` - Wallet configuration

**UI Components:**
- All files in `src/components/ui/` (shadcn/ui components)

### Smart Contracts (contracts/)

**Source:**
- `contracts/src/BettingPlatform.sol` - Main betting contract
- `contracts/src/TemporaryDeployFactory.sol` - Deployment factory

**Tests:**
- `contracts/test/BettingPlatform.t.sol` - Contract tests

**Scripts:**
- `contracts/script/Deploy.s.sol` - Deployment script

**Metadata:**
- `contracts/interfaces/metadata.json` - Contract ABI and addresses

## Step-by-Step Recreation

### Step 1: Initialize Project

```bash
# Create project directory
mkdir irys-betting-platform
cd irys-betting-platform

# Initialize package.json
pnpm init

# Install dependencies (copy from package.json)
pnpm install
```

### Step 2: Copy Configuration Files

Copy these files from the project:
- package.json
- tsconfig.json
- tsconfig.app.json
- tsconfig.node.json
- vite.config.ts
- tailwind.config.js
- postcss.config.js
- eslint.config.js
- components.json
- vercel.json
- index.html
- .gitignore
- .env.example

### Step 3: Create Source Structure

```bash
mkdir -p src/components/ui
mkdir -p src/utils
mkdir -p src/hooks
mkdir -p src/lib
mkdir -p src/pages
mkdir -p src/assets
mkdir -p public
mkdir -p plugins
```

### Step 4: Copy Source Files

Copy all files from:
- `src/components/` (CreateBet.tsx, BetsList.tsx, MyBets.tsx, etc.)
- `src/components/ui/` (all shadcn/ui components)
- `src/utils/` (evmConfig.ts, irysClient.ts, wagmiConfig.ts)
- `src/hooks/` (use-mobile.tsx, use-toast.ts)
- `src/lib/` (utils.ts)
- `src/pages/` (Index.tsx, Placeholder.tsx)
- `src/` (App.tsx, main.tsx, index.css, vite-env.d.ts)

### Step 5: Setup Smart Contracts

```bash
mkdir -p contracts/src
mkdir -p contracts/test
mkdir -p contracts/script
mkdir -p contracts/interfaces

# Copy contract files
# - contracts/src/BettingPlatform.sol
# - contracts/src/TemporaryDeployFactory.sol
# - contracts/test/BettingPlatform.t.sol
# - contracts/script/Deploy.s.sol
# - contracts/interfaces/metadata.json
# - contracts/foundry.toml
# - contracts/remappings.txt
```

### Step 6: Environment Setup

```bash
# Copy .env.example to .env
cp .env.example .env

# Edit .env with your values
VITE_CHAIN=devnet
VITE_WALLETCONNECT_PROJECT_ID=your_project_id
```

### Step 7: Install and Run

```bash
# Install dependencies
pnpm install

# Copy metadata
pnpm run prebuild

# Start development server
pnpm dev
```

## Alternative: Download Individual Files

Since you can't git push, you can:

1. **Use the CodeNut interface** to view and copy each file
2. **Create a new GitHub repository** and manually upload files
3. **Use Vercel CLI** to deploy directly:
   ```bash
   npm i -g vercel
   vercel
   ```

## Key Files List (Priority Order)

### Must Have (Core Functionality):
1. package.json
2. src/main.tsx
3. src/App.tsx
4. src/components/CreateBet.tsx
5. src/components/BetsList.tsx
6. src/components/MyBets.tsx
7. src/utils/evmConfig.ts
8. src/utils/wagmiConfig.ts
9. src/utils/irysClient.ts
10. contracts/interfaces/metadata.json
11. vite.config.ts
12. index.html
13. .env

### Important (Styling & Config):
14. tailwind.config.js
15. src/index.css
16. src/lib/utils.ts
17. tsconfig.json
18. vercel.json

### UI Components (shadcn/ui):
All files in src/components/ui/ (can be regenerated with shadcn CLI)

## Regenerating UI Components

If you don't want to copy all UI components manually:

```bash
# Install shadcn CLI
npx shadcn@latest init

# Add components as needed
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add input
npx shadcn@latest add label
npx shadcn@latest add toast
# ... etc
```

## Deployment Without Git

### Option 1: Vercel CLI
```bash
npm i -g vercel
cd irys-betting-platform
vercel
```

### Option 2: Drag & Drop
1. Build the project: `pnpm build`
2. Go to Vercel dashboard
3. Drag the `dist` folder to deploy

### Option 3: Create New Repo
1. Create new GitHub repository
2. Upload files via GitHub web interface
3. Connect to Vercel

## Support

If you need specific files, let me know and I can provide their complete contents.

## Next Steps

1. Copy all configuration files
2. Copy all source files
3. Copy contract files and metadata
4. Install dependencies
5. Set up environment variables
6. Run development server
7. Deploy to Vercel

For detailed deployment instructions, see DEPLOYMENT.md
