import { test, expect } from './fixtures/index'

const DEFAULT_COMPARE_URL
  = 'compare?from=2020-10-01&to=2021-10-01&in=hpi&st=all&location[]=K02000001&location[]=E12000007'

test.describe('Compare locations', () => {
  test.describe('Compare with another location tab', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto('browse')
      await page.getByRole('button', { name: 'select a different location' }).waitFor()
    })

    test('default query is set to United Kingdom', async ({ page }) => {
      const selectDifferentLocationButton = page.getByRole('button', { name: 'select a different location' })
      await expect(selectDifferentLocationButton).toHaveText(/United Kingdom/i)
    })

    test('clicking the compare with location tab shows a select another location button', async ({ page }) => {
      await page.getByRole('tab', { name: /compare with location/i }).first()
        .click()
      await expect(page.getByRole('button', { name: 'select another location' })).toBeVisible()
    })

    test('clicking select another location opens a location selection control', async ({ page }) => {
      await page.getByRole('tab', { name: /compare with location/i }).first()
        .click()
      await page.getByRole('button', { name: 'select another location' }).click()
      await expect(page.getByLabel('Search locations:')).toBeVisible()
    })

    test('typing a location and pressing enter routes to compare page with data table', async ({ page }) => {
      await page.getByRole('tab', { name: /compare with location/i }).first()
        .click()
      await page.getByRole('button', { name: 'select another location' }).click()
      await page.getByLabel('Search locations:').fill('London')
      await page.getByLabel('Search locations:').press('Enter')
      await expect(page).toHaveURL(/compare/)
      await expect(page.locator('.o-data-table')).toBeVisible()
    })
  })

  test.describe('Compare locations view - query parameters', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(DEFAULT_COMPARE_URL)
      await page.locator('.o-data-table').waitFor()
    })

    test('data type select menu is visible and can be changed', async ({ page }) => {
      const select = page.locator('.c-compare__selections label').filter({ hasText: /compare/i })
        .locator('select, .el-select')
        .first()
      await expect(select).toBeVisible()
    })

    test('changing data type refreshes the table', async ({ page }) => {
      const initialText = await page.locator('.o-data-table').innerText()
      await page.locator('.el-select').first()
        .click()
      await page.locator('.el-select-dropdown:visible .el-select-dropdown__item', { hasText: 'Average price' }).click()
      await expect(page.locator('.o-data-table')).not.toHaveText(initialText)
    })

    test('type select menu is visible', async ({ page }) => {
      const selects = page.locator('.el-select')
      expect(await selects.count()).toBeGreaterThan(1)
    })

    test('date range edit control is visible', async ({ page }) => {
      await expect(page.getByRole('button', { name: /change start or end date/i })).toBeVisible()
    })

    test('changing date range refreshes the table', async ({ page }) => {
      const urlBefore = page.url()
      await page.getByRole('button', { name: /change start or end date/i }).click()
      const dateDialog = page.getByRole('dialog', { name: 'Change the date range' })
      await expect(dateDialog).toBeVisible()
      await dateDialog.getByRole('button', { name: /cancel/i })
        .click()
      expect(page.url()).toBe(urlBefore)
    })
  })

  test.describe('Compare locations view - location parameters', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(DEFAULT_COMPARE_URL)
      await page.locator('.o-data-table').waitFor()
    })

    test('table shows columns for each specified location', async ({ page }) => {
      const headers = page.locator('.o-data-table thead th')
      expect(await headers.count()).toBeGreaterThan(2)
    })

    test('adding a location adds a new column to the table', async ({ page }) => {
      const initialHeaders = await page.locator('.o-data-table thead th').count()
      const addBtn = page.locator('.c-compare__locations--modify').last()
      await addBtn.click()
      await page.getByLabel('Search locations:').fill('Manchester')
      await page.getByLabel('Search locations:').press('Enter')
      await page.locator('.o-data-table').waitFor()
      const newHeaders = await page.locator('.o-data-table thead th').count()
      expect(newHeaders).toBeGreaterThan(initialHeaders)
    })

    test('up to 5 locations can be selected', async ({ page }) => {
      const locationItems = page.locator('.c-compare__location')
      expect(await locationItems.count()).toBeGreaterThanOrEqual(1)
      expect(await locationItems.count()).toBeLessThanOrEqual(5)
    })

    test('CSV download link is visible', async ({ page }) => {
      await expect(page.locator('.c-compare__download-csv')).toBeVisible()
    })

    test('JSON download link is visible', async ({ page }) => {
      await expect(page.locator('.c-compare__download-json')).toBeVisible()
    })

    test('CSV download link points to a CSV resource', async ({ page }) => {
      const href = await page.locator('.c-compare__download-csv').getAttribute('href')
      expect(href).toMatch(/\.csv/)
    })

    test('JSON download link points to a JSON resource', async ({ page }) => {
      const href = await page.locator('.c-compare__download-json').getAttribute('href')
      expect(href).toMatch(/\.json/)
    })

    test('print link opens a new browser window', async ({ page, context }) => {
      const [newPage] = await Promise.all([
        context.waitForEvent('page'),
        page.locator('.c-compare__print-link').click(),
      ])
      await newPage.waitForLoadState()
      expect(newPage.url()).toMatch(/compare/)
      await newPage.close()
    })
  })
})
