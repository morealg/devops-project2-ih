import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import './telemetry'
import App from './App.tsx'
// IMPORT TELEMETRY HERE TO ACTIVATE IT
import './telemetry' 

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
