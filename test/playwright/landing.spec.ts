import { test, expect } from '@playwright/test'

test.describe('Landing page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('')
  })

  test('page loads with appropriate body content', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'UK House Price Index', level: 1 })).toBeVisible()
    await expect(page.locator('#main-content')).toBeVisible()
  })

  test('page contains multiple links to the application', async ({ page }) => {
    const baseURL = page.url().replace(/\/$/, '')
    const origin = new URL(baseURL).origin
    const internalLinks = page.locator(`a[href^="${origin}"]`)
    await expect(internalLinks).toHaveCount(await internalLinks.count())
    expect(await internalLinks.count()).toBeGreaterThan(1)
  })

  test('page contains multiple links to external websites', async ({ page }) => {
    const allLinks = await page.locator('a[href]').all()
    const externalLinks = await Promise.all(
      allLinks.map(async (link) => {
        const href = await link.getAttribute('href')
        return href && href.startsWith('http') && !href.includes('localhost') ? link : null
      }),
    )
    expect(externalLinks.filter(Boolean).length).toBeGreaterThan(1)
  })
})
