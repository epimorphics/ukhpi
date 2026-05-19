import { test, expect } from './fixtures/index'

test.describe('Change language', () => {
  test('clicking Cymraeg changes the page to Welsh', async ({ page }) => {
    await page.goto('')
    await page.getByRole('navigation', { name: 'language selector' }).getByRole('link', { name: 'Cymraeg' })
      .click()
    await expect(page).toHaveURL(/lang=cy/)
    await expect(page.getByRole('link', { name: 'pori' })).toBeVisible()
    await expect(page.getByRole('heading', { name: 'Mynegai Prisiau Tai y DU', level: 1 })).toBeVisible()
  })

  test('navigation items are displayed in Welsh after language switch', async ({ page }) => {
    await page.goto('?lang=cy')
    await expect(page.getByRole('link', { name: 'pori' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'cymharu lleoliadau' })).toBeVisible()
  })

  test('clicking the header logo from the Welsh page returns to the home page', async ({ page }) => {
    await page.goto('?lang=cy')
    await page.locator('header#global-header').getByRole('link', { name: 'UKHPI Logo' })
      .click()
    await expect(page).toHaveURL(/lang=cy/)
    await expect(page.getByRole('heading', { name: 'Mynegai Prisiau Tai y DU', level: 1 })).toBeVisible()
  })

  test('clicking English link restores English language', async ({ page }) => {
    await page.goto('?lang=cy')
    await page.getByRole('navigation', { name: 'language selector' }).getByRole('link', { name: 'English' })
      .click()
    await expect(page).not.toHaveURL(/lang=cy/)
    await expect(page.getByRole('link', { name: 'browse' })).toBeVisible()
  })
})
