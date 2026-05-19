import { type Page, type Locator, expect } from '@playwright/test'

export class DateRangeModal {
  private readonly dialog: Locator

  constructor (private readonly page: Page) {
    this.dialog = page.locator('.el-dialog').filter({ hasText: 'Change the date range' })
  }

  async open () {
    await this.page.getByRole('button', { name: /change start or end date/ }).click()
    await expect(this.dialog).toBeVisible()
  }

  async close () {
    await this.dialog.getByRole('button', { name: 'Close' }).click()
    await expect(this.dialog).toBeHidden()
  }

  async cancel () {
    await this.dialog.getByRole('button', { name: 'cancel' }).click()
    await expect(this.dialog).toBeHidden()
  }

  async confirm () {
    await this.dialog.getByRole('button', { name: 'confirm' }).click()
  }

  getStartInput (): Locator {
    return this.dialog.getByLabel('Start').locator('input')
  }

  getEndInput (): Locator {
    return this.dialog.getByLabel('End').locator('input')
  }

  async getStartValue () {
    return this.getStartInput().inputValue()
  }

  async getEndValue () {
    return this.getEndInput().inputValue()
  }

  async clearStart () {
    const input = this.getStartInput()
    await input.hover()
    const clearBtn = this.dialog.getByLabel('Start').locator('.el-input__clear')
    if (await clearBtn.isVisible()) {
      await clearBtn.click()
    } else {
      await input.fill('')
    }
  }

  async setStart (year: number, month: number) {
    const value = `${year}-${String(month).padStart(2, '0')}`
    await this.getStartInput().fill(value)
    await this.getStartInput().press('Enter')
  }

  async setEnd (year: number, month: number) {
    const value = `${year}-${String(month).padStart(2, '0')}`
    await this.getEndInput().fill(value)
    await this.getEndInput().press('Enter')
  }

  async getValidationMessage () {
    const alert = this.dialog.locator('.el-alert')
    await expect(alert).toBeVisible()
    return alert.locator('.el-alert__title').textContent()
  }

  isVisible () {
    return this.dialog.isVisible()
  }
}
