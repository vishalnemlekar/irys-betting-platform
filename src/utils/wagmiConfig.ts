import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { chainConfig } from './evmConfig';

export const wagmiConfig = getDefaultConfig({
  appName: 'Irys Betting Platform',
  projectId: 'YOUR_PROJECT_ID', // Get from https://cloud.walletconnect.com
  chains: [chainConfig as any],
  ssr: false,
});
