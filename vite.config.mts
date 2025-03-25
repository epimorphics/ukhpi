import { defineConfig, loadEnv } from 'vite'
import Erb from 'vite-plugin-erb'
import ViteRails from 'vite-plugin-rails'
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
      ViteRails({
        envVars: { RAILS_ENV: 'development' },
        envOptions: { defineOn: 'import.meta.env' },
        fullReload: {
          additionalPaths: ['config/routes.rb', 'app/views/**/*'],
          delay: 300
        }
      }),
      vue(),
      // Put the Sentry vite plugin after all other plugins
      sentryVitePlugin({
        org: env.SENTRY_ORG,
        project: env.SENTRY_PROJECT,
        authToken: env.SENTRY_AUTH_TOKEN,
        telemetry: mode === 'production',
        sourcemaps: {
          // assets: ['app/assets'],
          ignore: ['node_modules']
        }
      })
    ],
    optimizeDeps: {
      esbuildOptions: {
        target: 'esnext'
      }
    },
    build: {
      sourcemap: true, // Source map generation must be turned on for Sentry to work
      target: 'esnext'
    },
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./app/javascript', import.meta.url)),
        '@assets': fileURLToPath(new URL('./app/assets', import.meta.url))
      }
    }
  }
})
