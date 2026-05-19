import { test, expect } from '@playwright/test'

test('landing page renders', async ({ page }) => {
  await page.goto('/')
  await expect(page).toHaveTitle(/House Price Index/i)
})
