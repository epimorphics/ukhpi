import { defineConfig, devices } from '@playwright/test'

const rawBaseURL = process.env['E2E_BASE_URL'] ?? 'http://localhost:3000/'
const baseURL = rawBaseURL.endsWith('/') ? rawBaseURL : `${rawBaseURL}/`

export default defineConfig({
  testDir: 'test/playwright',
  outputDir: 'tmp/test-results',
  reporter: [['html', { outputFolder: 'tmp/playwright-report', open: 'never' }]],

  use: {
    baseURL,
    screenshot: 'only-on-failure',
    actionTimeout: 15_000,
    navigationTimeout: 15_000,
    ...(process.env['E2E_USERNAME']
      ? {
        httpCredentials: {
          username: process.env['E2E_USERNAME'],
          password: process.env['E2E_PASSWORD'] ?? '',
        },
      }
      : {}),
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  webServer: process.env['E2E_BASE_URL']
    ? undefined
    : {
      command: 'bin/rails server',
      url: 'http://localhost:3000',
      reuseExistingServer: true,
      timeout: 60_000,
    },
})
