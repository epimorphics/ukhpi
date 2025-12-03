import { defineConfig, loadEnv } from 'vite'
import gzipPlugin from 'rollup-plugin-gzip'
import ViteRails from 'vite-plugin-rails'
import ViteYaml from '@modyfi/vite-plugin-yaml'
import vue from '@vitejs/plugin-vue2'
import { fileURLToPath, URL } from 'node:url'
import { sentryVitePlugin } from '@sentry/vite-plugin'

export default defineConfig(({ mode }) => {
  /*
   * Load env file based on `mode` in the current working directory.
   * Set the third parameter to '' to load all env regardless of the
   * `VITE_` prefix.
   */
  const env = loadEnv(mode, process.cwd(), '')

  return {

    envPrefix: ['VITE_', 'RAILS_', 'HMLR_', 'LOG_', 'SENTRY_'], // default: 'VITE_'
    plugins: [
      // Create gzip copies of relevant assets
      gzipPlugin(),
      // Integrate with ViteRails gem
      ViteRails(),
      // Load YAML files as JSON - useful for translation files
      ViteYaml(),
      // Enable Vue 2 support
      vue(),
      // Put the Sentry vite plugin after all other plugins
      sentryVitePlugin({
        authToken: env.SENTRY_AUTH_TOKEN,
        org: env.SENTRY_ORG,
        project: env.SENTRY_PROJECT,
        release: {
          name: `${env.SENTRY_PROJECT}@${env.HMLR_APP_VERSION || '1.0.0'}`,
        },

        sourcemaps: {
          ignore: ['node_modules'],
        },
        telemetry: env.RAILS_ENV === 'production',
      }),
    ],
    build: {
      assetsInlineLimit: 0, // Prevents inlining of all assets, resolves issues with graph icons
      base: env.VITE_RUBY_BASE,
      sourcemap: 'hidden', // Generate but don't expose in production
      target: 'esnext',
    },
    css: {
      preprocessorOptions: {
        sass: {
          api: 'modern-compiler',
          includePaths: ['node_modules'],
          quietDeps: true,
        },
        scss: {
          api: 'modern-compiler',
          includePaths: ['node_modules'],
          quietDeps: true,
        },
      },
    },
    optimizeDeps: {
      esbuildOptions: {
        target: 'esnext',
      },
      optimizeDeps: {
        include: ['govuk_frontend_toolkit', 'govuk-elements-sass', 'element-ui', 'leaflet'],
      },
    },
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./app/javascript', import.meta.url)),
        '@assets': fileURLToPath(new URL('./app/assets', import.meta.url)),
      },
    },
  }
})
