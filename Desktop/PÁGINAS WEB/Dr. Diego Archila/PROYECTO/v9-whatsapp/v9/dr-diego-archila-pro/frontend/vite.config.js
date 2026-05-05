import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// El backend corre en :4000. En desarrollo, el frontend hace proxy de /api -> backend.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true,
      },
    },
  },
})
