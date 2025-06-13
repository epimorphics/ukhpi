import { defineConfig, loadEnv } from 'vite'
import Erb from 'vite-plugin-erb'
import ViteRails from 'vite-plugin-rails'
import ViteYaml from '@modyfi/vite-plugin-yaml'
import vue from '@vitejs/plugin-vue2'
import { fileURLToPath, URL } from 'node:url'
import { sentryVitePlugin } from '@sentry/vite-plugin'

export default defineConfig(({ command, mode }) => {
  // Load env file based on `mode` in the current working directory.
  // Set the third parameter to '' to load all env regardless of the
  // `VITE_` prefix.
  const env = loadEnv(mode, process.cwd(), '')

  return {

    envPrefix: ['VITE_', 'RAILS_', 'HMLR_', 'LOG_', 'SENTRY_'], // default: 'VITE_'
    plugins: [
      Erb(),
      ViteRails(),
      ViteYaml(),
      vue(),
      // Put the Sentry vite plugin after all other plugins
      sentryVitePlugin({
        org: env.SENTRY_ORG,
        project: env.SENTRY_PROJECT,
        authToken: env.SENTRY_AUTH_TOKEN,
        telemetry: env.RAILS_ENV === 'production',
        sourcemaps: {
          ignore: ['node_modules']
        }
      })
    ],
    build: {
      assetsInlineLimit: 0, // Prevents inlining of all assets
      base: env.RAILS_ENV === 'production' ? '/app/ukhpi/' : '/',
      sourcemap: true, // Source map generation must be turned on for Sentry to work
      target: 'esnext'
    },
    css: {
      preprocessorOptions: {
        sass: {
          api: 'modern-compiler',
          includePaths: ['node_modules'],
          quietDeps: true
        },
        scss: {
          api: 'modern-compiler',
          includePaths: ['node_modules'],
          quietDeps: true
        }
      }
    },
    optimizeDeps: {
      esbuildOptions: {
        target: 'esnext'
      },
      optimizeDeps: {
        include: ['govuk_frontend_toolkit', 'govuk-elements-sass', 'element-ui', 'leaflet']
      }
    },
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./app/javascript', import.meta.url)),
        '@assets': fileURLToPath(new URL('./app/assets', import.meta.url))
      }
    }
  }
})
