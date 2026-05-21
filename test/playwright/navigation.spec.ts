import { test, expect } from './fixtures/index'

test.describe('Header and primary navigation', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('')
  })

  test('custom header is visible', async ({ page }) => {
    await expect(page.locator('header#global-header')).toBeVisible()
  })

  test('UKHPI logo is shown in the header', async ({ page }) => {
    const logo = page.locator('header#global-header').locator('img[src*="ukhpi-icon"]')
    await expect(logo).toBeVisible()
  })

  test('clicking Browse routes to the data display', async ({ page }) => {
    await page.locator('nav[aria-label="application menu"]').getByRole('link', { name: 'browse' })
      .click()
    await expect(page).toHaveURL(/browse/)
  })

  test('clicking Compare locations routes to the comparison view', async ({ page }) => {
    await page.locator('nav[aria-label="application menu"]').getByRole('link', { name: 'compare locations' })
      .click()
    await expect(page).toHaveURL(/compare/)
  })

  test('SPARQL query link points to the SPARQL console', async ({ page }) => {
    const link = page.locator('nav[aria-label="application menu"]').getByRole('link', { name: 'SPARQL query' })
    await expect(link).toHaveAttribute('href', /qonsole/)
  })

  test('user guide link points to the user guide PDF', async ({ page }) => {
    const link = page.locator('nav[aria-label="application menu"]').getByRole('link', { name: 'user guide' })
    await expect(link).toHaveAttribute('href', /ukhpi-user-guide/)
  })

  test('clicking About UKHPI routes to the about page', async ({ page }) => {
    await page.locator('nav[aria-label="application menu"]').getByRole('link', { name: 'about UKHPI', exact: true })
      .click()
    await expect(page).toHaveURL(/doc/)
  })

  test('clicking Change history routes to the changelog', async ({ page }) => {
    await page.locator('nav[aria-label="application menu"]').getByRole('link', { name: 'change history' })
      .click()
    await expect(page).toHaveURL(/changelog/)
  })
})

test.describe('URL redirects', () => {
  test('/explore redirects to /browse', async ({ page }) => {
    await page.goto('explore')
    await expect(page).toHaveURL(/browse/)
  })
})
