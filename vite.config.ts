import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import glsl from 'vite-plugin-glsl'


// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss(), glsl()],
  server: {
    host: 'localhost',
    cors: {allowedHeaders: ['*'],},
    hmr: {
      host: 'localhost',
      protocol: 'ws',
    },
  },
  build: {
    minify: true,
    manifest: true,
    outDir: 'build',
    rollupOptions: {
      input: './src/main.tsx',
      output: {
        format: 'umd',
        entryFileNames: 'main.js',
        esModule: false,
        compact: true,
        globals: {
          jquery: '$',
        },
      },
      external: ['jquery'],
    },
  },
})
