import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    host: '127.0.0.1',
    port: 5222,
    strictPort: true,
    proxy: {
      '/auth': {
        target: 'http://127.0.0.1:3001',
        changeOrigin: false,
      },
      '/api': {
        target: 'http://127.0.0.1:3001',
        changeOrigin: false,
      },
    },
  },
});