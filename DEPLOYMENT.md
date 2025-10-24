# Deployment Guide - Irys Betting Platform

## Prerequisites
- Vercel account (sign up at https://vercel.com)
- Git repository (GitHub, GitLab, or Bitbucket)
- WalletConnect Project ID (optional, for production)

## Step-by-Step Deployment to Vercel

### 1. Prepare Your Repository
```bash
# Initialize git if not already done
git init

# Add all files
git add .

# Commit your changes
git commit -m "Initial commit - Irys Betting Platform"

# Create a new repository on GitHub/GitLab/Bitbucket
# Then push your code
git remote add origin <your-repository-url>
git push -u origin main
```

### 2. Deploy to Vercel

#### Option A: Using Vercel Dashboard (Recommended)
1. Go to https://vercel.com and sign in
2. Click "Add New Project"
3. Import your Git repository
4. Configure project settings:
   - **Framework Preset**: Vite
   - **Build Command**: `pnpm build` (auto-detected)
   - **Output Directory**: `dist` (auto-detected)
   - **Install Command**: `pnpm install` (auto-detected)

5. Add Environment Variables:
   - Click "Environment Variables"
   - Add the following:
     ```
     VITE_CHAIN=devnet
     VITE_WALLETCONNECT_PROJECT_ID=21fef48091f12692cad574a6f7753643
     ```
   - Note: Get your own WalletConnect Project ID from https://cloud.walletconnect.com for production

6. Click "Deploy"
7. Wait for deployment to complete (2-3 minutes)
8. Your app will be live at `https://your-project-name.vercel.app`

#### Option B: Using Vercel CLI
```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Follow the prompts:
# - Set up and deploy? Yes
# - Which scope? Select your account
# - Link to existing project? No
# - Project name? (press enter for default)
# - Directory? ./ (press enter)
# - Override settings? No

# Add environment variables
vercel env add VITE_CHAIN
# Enter: devnet

vercel env add VITE_WALLETCONNECT_PROJECT_ID
# Enter: 21fef48091f12692cad574a6f7753643

# Deploy to production
vercel --prod
```

### 3. Post-Deployment Configuration

#### Update WalletConnect Project Settings
1. Go to https://cloud.walletconnect.com
2. Create a new project or use existing one
3. Add your Vercel domain to the allowlist:
   - Go to Project Settings
   - Add `https://your-project-name.vercel.app` to allowed origins
4. Update environment variable with your Project ID:
   ```bash
   vercel env add VITE_WALLETCONNECT_PROJECT_ID production
   # Enter your actual Project ID
   ```

#### Configure Custom Domain (Optional)
1. In Vercel Dashboard, go to your project
2. Click "Settings" → "Domains"
3. Add your custom domain
4. Follow DNS configuration instructions
5. Update WalletConnect allowlist with custom domain

### 4. Verify Deployment

Visit your deployed app and test:
- ✅ Wallet connection works
- ✅ Create bet functionality
- ✅ Browse bets
- ✅ Invest in bets
- ✅ Settle bets
- ✅ Claim rewards

### 5. Continuous Deployment

Vercel automatically deploys on every push to your main branch:
```bash
# Make changes to your code
git add .
git commit -m "Update feature"
git push

# Vercel will automatically deploy the changes
```

## Environment Variables Reference

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `VITE_CHAIN` | Blockchain network (devnet/mainnet) | Yes | devnet |
| `VITE_WALLETCONNECT_PROJECT_ID` | WalletConnect Project ID | Yes | - |

## Troubleshooting

### Build Fails
- Check that `contracts/interfaces/metadata.json` exists
- Verify all dependencies are in `package.json`
- Check build logs in Vercel dashboard

### Wallet Connection Issues
- Verify WalletConnect Project ID is correct
- Check that your domain is in WalletConnect allowlist
- Clear browser cache and try again

### Contract Interaction Fails
- Ensure you're connected to Sepolia testnet
- Verify contract address in `contracts/interfaces/metadata.json`
- Check that you have Sepolia ETH for gas fees

## Production Checklist

Before going to production:
- [ ] Get your own WalletConnect Project ID
- [ ] Update environment variables in Vercel
- [ ] Add production domain to WalletConnect allowlist
- [ ] Test all features on production URL
- [ ] Set up custom domain (optional)
- [ ] Enable Vercel Analytics (optional)
- [ ] Configure error monitoring (optional)

## Smart Contract Deployment

The current deployment uses CodeNut devnet (Ethereum Sepolia fork):
- **Contract**: `0xaDEa946285AE8c49d5D9696B559d5F615a99D8D7`
- **Network**: devnet (Chain ID: 20258)
- **RPC**: https://dev-rpc.codenut.dev

For mainnet deployment:
1. Deploy contract to Ethereum mainnet using Foundry
2. Update `contracts/interfaces/metadata.json` with mainnet contract address
3. Set `VITE_CHAIN=mainnet` in Vercel environment variables
4. Redeploy the application

## Support

For issues or questions:
- Check Vercel documentation: https://vercel.com/docs
- WalletConnect docs: https://docs.walletconnect.com
- Irys docs: https://docs.irys.xyz
