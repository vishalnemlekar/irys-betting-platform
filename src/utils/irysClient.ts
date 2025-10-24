import Irys from '@irys/sdk';
import { BrowserProvider } from 'ethers';

/**
 * Initialize Irys client for permanent data storage
 * Uses Ethereum for payment
 */
export const getIrysClient = async (walletClient: any) => {
  // Create ethers provider from wagmi wallet client
  const provider = new BrowserProvider(walletClient);
  const signer = await provider.getSigner();

  const irys = new Irys({
    network: 'mainnet', // or 'devnet' for testing
    token: 'ethereum',
    key: signer,
  });

  await irys.ready();
  return irys;
};

/**
 * Upload bet data to Irys and return transaction ID
 */
export const uploadBetToIrys = async (
  provider: any,
  betData: {
    title: string;
    description: string;
    outcomes: string[];
    investmentDeadline: number;
    settlementDeadline: number;
    creator: string;
  }
): Promise<string> => {
  const irys = await getIrysClient(provider);
  
  const dataToUpload = JSON.stringify(betData);
  
  try {
    const receipt = await irys.upload(dataToUpload, {
      tags: [
        { name: 'Content-Type', value: 'application/json' },
        { name: 'App-Name', value: 'IrysBettingPlatform' },
        { name: 'Type', value: 'Bet' },
      ],
    });
    
    return receipt.id;
  } catch (error) {
    console.error('Error uploading to Irys:', error);
    throw new Error('Failed to upload bet data to Irys');
  }
};

/**
 * Retrieve bet data from Irys using transaction ID
 */
export const getBetFromIrys = async (txId: string) => {
  try {
    const response = await fetch(`https://gateway.irys.xyz/${txId}`);
    if (!response.ok) {
      throw new Error('Failed to fetch from Irys');
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching from Irys:', error);
    throw new Error('Failed to retrieve bet data from Irys');
  }
};
