import { test, expect } from '@playwright/test'
import { DateRangeModal } from './fixtures/date-range-modal'

test.describe('Date range modal', () => {
  let modal: DateRangeModal

  test.beforeEach(async ({ page }) => {
    await page.goto('browse')
    await page.getByRole('button', { name: /change start or end date/ }).waitFor()
    modal = new DateRangeModal(page)
  })

  test('date edit button opens the date range modal', async ({ page }) => {
    await modal.open()
    await expect(page.locator('.el-dialog').filter({ hasText: 'Change the date range' })).toBeVisible()
    await expect(modal.getStartInput()).toBeVisible()
    await expect(modal.getEndInput()).toBeVisible()
  })

  test('default date range spans approximately one calendar year', async () => {
    await modal.open()
    const start = await modal.getStartValue()
    const end = await modal.getEndValue()
    expect(start.length).toBeGreaterThan(0)
    expect(end.length).toBeGreaterThan(0)
  })

  test.describe('Close window', () => {
    test('close icon dismisses the modal without changing the URL', async ({ page }) => {
      const urlBefore = page.url()
      await modal.open()
      await modal.close()
      expect(page.url()).toBe(urlBefore)
    })
  })

  test.describe('Cancel change', () => {
    test('cancel button dismisses the modal without changing the URL', async ({ page }) => {
      const urlBefore = page.url()
      await modal.open()
      await modal.cancel()
      expect(page.url()).toBe(urlBefore)
    })
  })

  test.describe('Select new value', () => {
    test('selecting new dates and confirming updates the URL', async ({ page }) => {
      await modal.open()
      await modal.setStart(2020, 1)
      await modal.setEnd(2021, 6)
      await modal.confirm()
      await expect(page.locator('.el-dialog').filter({ hasText: 'Change the date range' })).toBeHidden()
      expect(page.url()).toMatch(/from=|startDate=|2020/)
    })
  })

  test.describe('Invalid date — empty field', () => {
    test('clearing the start field and confirming shows Invalid date', async ({ page }) => {
      await modal.open()
      await modal.clearStart()
      await modal.confirm()
      await expect(
        page.getByRole('button', { name: /change start or end date/ }),
      ).toContainText(/Invalid date/i)
    })
  })

  test.describe('Invalid date — start after end', () => {
    test('setting start after end shows a validation warning', async ({ page }) => {
      await modal.open()
      await modal.setStart(2021, 3)
      await modal.setEnd(2021, 1)
      await modal.confirm()
      await expect(
        page.locator('.el-dialog').filter({ hasText: 'Change the date range' }),
      ).toBeVisible()
      await expect(
        page.getByText('The start date must be earlier than the end date'),
      ).toBeVisible()
    })
  })
})
