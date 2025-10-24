/**
 * EVM Configuration for Betting Platform
 * 
 * To build for different chains, set the VITE_CHAIN environment variable:
 * VITE_CHAIN=devnet pnpm run build       (for local development)
 * VITE_CHAIN=irys_testnet pnpm run build (for Irys testnet - default)
 * VITE_CHAIN=mainnet pnpm run build      (for production)
 */

import metadata from '../metadata.json';

const targetChainName = import.meta.env.VITE_CHAIN || 'irys_testnet';

// Find the chain configuration by network name
const evmConfig = metadata.chains.find(chain => chain.network === targetChainName);

if (!evmConfig) {
  throw new Error(`Chain '${targetChainName}' not found in metadata.json`);
}

// Get the BettingPlatform contract
const contractInfo = evmConfig.contracts.find(c => c.contractName === 'BettingPlatform');

if (!contractInfo) {
  throw new Error('BettingPlatform contract not found in metadata.json');
}

export const selectedChain = evmConfig;
export const contractAddress = contractInfo.address as `0x${string}`;
export const contractABI = contractInfo.abi;
export const chainId = parseInt(evmConfig.chainId);
export const rpcUrl = evmConfig.rpc_url;
export const networkName = evmConfig.network;

// Chain configuration for wagmi
export const chainConfig = {
  id: chainId,
  name: networkName,
  network: networkName,
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: { http: [rpcUrl] },
    public: { http: [rpcUrl] },
  },
} as const;
