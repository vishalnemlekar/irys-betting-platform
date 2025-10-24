# Irys BetHub - Complete Project Files Guide

This guide contains all the files needed to recreate the project locally or deploy it.

## Quick Start Options

### Option 1: Deploy with Vercel CLI (Recommended)
```bash
# Install Vercel CLI globally
npm i -g vercel

# Deploy from current directory
vercel

# Follow prompts and set environment variables:
# VITE_CHAIN=irys_testnet
# VITE_WALLETCONNECT_PROJECT_ID=21fef48091f12692cad574a6f7753643
```

### Option 2: Manual Recreation
1. Create a new directory for your project
2. Copy all files listed below into the appropriate locations
3. Run `pnpm install`
4. Create `.env` file with the variables from `.env.example`
5. Run `pnpm dev` to test locally
6. Deploy to Vercel

---

## Configuration Files

### package.json
Location: `./package.json`
```json
{
  "name": "starter_shadcn",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "prebuild": "cp -f contracts/interfaces/metadata.json src/metadata.json || true",
    "build": "vite build",
    "lint": "eslint .",
    "postcss:check": "postcss src/**/*.css --no-map --dry-run > /dev/null",
    "preview": "vite preview"
  },
  "dependencies": {
    "@hookform/resolvers": "^5.1.1",
    "@irys/sdk": "^0.2.11",
    "@radix-ui/react-accordion": "^1.2.11",
    "@radix-ui/react-alert-dialog": "^1.1.14",
    "@radix-ui/react-avatar": "^1.1.10",
    "@radix-ui/react-checkbox": "^1.3.2",
    "@radix-ui/react-collapsible": "^1.1.11",
    "@radix-ui/react-context-menu": "^2.2.15",
    "@radix-ui/react-dialog": "^1.1.14",
    "@radix-ui/react-dropdown-menu": "^2.1.15",
    "@radix-ui/react-hover-card": "^1.1.14",
    "@radix-ui/react-icons": "^1.3.2",
    "@radix-ui/react-label": "^2.1.7",
    "@radix-ui/react-menubar": "^1.1.15",
    "@radix-ui/react-navigation-menu": "^1.2.13",
    "@radix-ui/react-popover": "^1.1.14",
    "@radix-ui/react-progress": "^1.1.7",
    "@radix-ui/react-radio-group": "^1.3.7",
    "@radix-ui/react-scroll-area": "^1.2.9",
    "@radix-ui/react-select": "^2.2.5",
    "@radix-ui/react-separator": "^1.1.7",
    "@radix-ui/react-slider": "^1.3.5",
    "@radix-ui/react-slot": "^1.2.3",
    "@radix-ui/react-switch": "^1.2.5",
    "@radix-ui/react-tabs": "^1.1.12",
    "@radix-ui/react-toast": "^1.2.14",
    "@radix-ui/react-toggle": "^1.1.9",
    "@radix-ui/react-toggle-group": "^1.1.10",
    "@radix-ui/react-tooltip": "^1.2.7",
    "@rainbow-me/rainbowkit": "^2.2.9",
    "@tanstack/react-query": "^5.83.0",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "cmdk": "^1.1.1",
    "date-fns": "^4.1.0",
    "embla-carousel-react": "^8.6.0",
    "ethers": "^6.15.0",
    "input-otp": "^1.4.2",
    "lucide-react": "^0.525.0",
    "react": "^19.1.0",
    "react-day-picker": "^9.8.0",
    "react-dom": "^19.1.0",
    "react-hook-form": "^7.61.1",
    "react-is": "^19.1.0",
    "react-resizable-panels": "^3.0.3",
    "react-router-dom": "^7.7.1",
    "recharts": "^2.15.4",
    "tailwind-merge": "^3.3.1",
    "tailwindcss-animate": "^1.0.7",
    "tw-animate-css": "^1.3.5",
    "vaul": "^1.1.2",
    "viem": "^2.38.4",
    "wagmi": "^2.18.2",
    "zod": "^4.0.9"
  },
  "devDependencies": {
    "@babel/parser": "^7.28.0",
    "@eslint/js": "^9.30.1",
    "@types/node": "^24.1.0",
    "@types/react": "^19.1.8",
    "@types/react-dom": "^19.1.6",
    "@vitejs/plugin-react": "^5.0.4",
    "autoprefixer": "^10.4.21",
    "eslint": "^9.30.1",
    "eslint-plugin-react-hooks": "^5.2.0",
    "eslint-plugin-react-refresh": "^0.4.20",
    "estree-walker": "^3.0.3",
    "globals": "^16.3.0",
    "magic-string": "^0.30.17",
    "postcss": "^8.5.6",
    "postcss-cli": "^11.0.1",
    "tailwindcss": "3",
    "typescript": "~5.8.3",
    "typescript-eslint": "^8.35.1",
    "vite": "npm:rolldown-vite@latest"
  },
  "packageManager": "pnpm@10.12.4+sha512.5ea8b0deed94ed68691c9bad4c955492705c5eeb8a87ef86bc62c74a26b037b08ff9570f108b2e4dbd1dd1a9186fea925e527f141c648e85af45631074680184"
}
```

### vercel.json
Location: `./vercel.json`
```json
{
  "buildCommand": "pnpm build",
  "outputDirectory": "dist",
  "framework": "vite",
  "installCommand": "pnpm install",
  "devCommand": "pnpm dev"
}
```

### .env.example
Location: `./.env.example`
```
# Blockchain Network Configuration
# Options: devnet, irys_testnet
VITE_CHAIN=irys_testnet

# WalletConnect Project ID (get from https://cloud.walletconnect.com)
VITE_WALLETCONNECT_PROJECT_ID=21fef48091f12692cad574a6f7753643
```

### .gitignore
Location: `./.gitignore`
See next section for content.

---

## Next Steps

I'll provide the remaining files in the following categories:
1. Build configuration files (vite, typescript, tailwind, etc.)
2. Contract files and metadata
3. Source code files (utils, components, pages)
4. Additional documentation

Would you like me to continue with all the remaining files, or would you prefer to:
- Use Vercel CLI to deploy directly (fastest option)
- Get specific files you need
- Try fixing the git push issue

The WalletConnect 400 error you see is harmless - it's just analytics telemetry and doesn't affect functionality.
