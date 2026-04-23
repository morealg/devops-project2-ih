// ============================================================
// FILE: frontend/vite.config.ts
// PURPOSE: Configures the Vite build tool.
//
// KEY CHANGE FOR CLOUD-READINESS (Step 1 - API Routing):
//   In development: proxy /api calls to localhost:8080
//   In production:  the built app uses relative /api paths
//                   which the Application Gateway routes to the backend VM
// ============================================================

import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],

  server: {
    // DEV ONLY: This proxy runs the local dev server.
    // When you type /api/ingredients in code, Vite forwards it to Spring Boot.
    // This block has NO effect on the production build.
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        // WHY changeOrigin: Prevents CORS errors during local development
      }
    }
  },

  build: {
    // Output directory for production build (used by GitHub Actions)
    outDir: 'dist',
    // Generate source maps for Application Insights error tracking (Step 4)
    sourcemap: true,
  },

  // ── PRODUCTION API BASE URL ──────────────────────────────
  // VITE_API_BASE_URL is set to "" in the GitHub Actions workflow.
  // This means all API calls use relative paths: /api/ingredients
  // The Application Gateway then routes /api/* → Backend VM.
  //
  // In your React code, use it like this:
  //   const base = import.meta.env.VITE_API_BASE_URL ?? ""
  //   fetch(`${base}/api/ingredients`)
  // ─────────────────────────────────────────────────────────
})

