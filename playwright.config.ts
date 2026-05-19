import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: 'test/playwright',
  outputDir: 'tmp/test-results',
  reporter: [['html', { outputFolder: 'tmp/playwright-report', open: 'never' }]],

  use: {
    baseURL: 'http://localhost:3002/app/ukhpi',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  webServer: {
    command: 'bin/rails server',
    url: 'http://localhost:3002',
    reuseExistingServer: true,
    timeout: 30_000,
  },
})
