import { test, expect } from './fixtures/index'

test.describe('Landing page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('')
  })

  test('page loads with appropriate body content', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'UK House Price Index', level: 1 })).toBeVisible()
    await expect(page.locator('#main-content')).toBeVisible()
  })

  test('page contains multiple links to the application', async ({ page }) => {
    const internalLinks = page.locator('a[href^="/"]')
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

  test('page contains introductory body copy about the search tool', async ({ page }) => {
    await expect(page.getByText('Use the search tool to find house price trends in the UK')).toBeVisible()
  })

  test('headline average price figure is shown', async ({ page }) => {
    await expect(page.locator('.c-headline-figure__average-price')).toContainText(/£[\d,]+/)
  })

  test('headline monthly change figure is shown', async ({ page }) => {
    await expect(page.locator('.c-headline-figure__monthly-change')).toContainText(
      /(remained the same)|((fallen|risen) by [\d.]+%)/,
    )
  })

  test('search CTA link navigates to the browse page', async ({ page }) => {
    await page.getByRole('link', { name: 'search the UK house price index' }).click()
    await expect(page).toHaveURL(/browse/)
    await expect(page.getByRole('heading', { name: 'House Price Statistics', level: 1 })).toBeVisible()
  })
})
