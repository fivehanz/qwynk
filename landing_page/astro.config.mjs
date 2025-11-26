// @ts-check
import { defineConfig } from 'astro/config';

import tailwindcss from '@tailwindcss/vite';
import svelte from '@astrojs/svelte';
import cloudflare from '@astrojs/cloudflare';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  site: 'https://qwynk.jsmx.org',
  vite: {
    plugins: [tailwindcss()]
  },

  integrations: [svelte(), sitemap()],
  adapter: cloudflare()
});