import { defineConfig, devices } from '@playwright/test'

const baseURL = process.env['PLAYWRIGHT_BASE_URL'] ?? 'http://localhost:3000/'

export default defineConfig({
  testDir: 'test/playwright',
  outputDir: 'tmp/test-results',
  reporter: [['html', { outputFolder: 'tmp/playwright-report', open: 'never' }]],

  use: {
    baseURL,
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  webServer: process.env['PLAYWRIGHT_BASE_URL']
    ? undefined
    : {
      command: 'bin/rails server',
      url: 'http://localhost:3000',
      reuseExistingServer: true,
      timeout: 60_000,
    },
})
