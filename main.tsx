import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { WagmiProvider } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { RainbowKitProvider } from '@rainbow-me/rainbowkit'
import { wagmiConfig } from './utils/wagmiConfig'
import './index.css'
import '@rainbow-me/rainbowkit/styles.css'
import App from './App.tsx'
import { withErrorOverlay } from './components/with-error-overlay'

const AppWithErrorOverlay = withErrorOverlay(App)
const queryClient = new QueryClient()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          <AppWithErrorOverlay />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  </StrictMode>,
)
