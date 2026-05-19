import { type Page, type Locator, expect } from '@playwright/test'

export class LocationModal {
  private readonly dialog: Locator
  private readonly searchInput: Locator

  constructor (private readonly page: Page) {
    this.dialog = page.locator('.el-dialog').filter({ hasText: 'Choose a different region or location' })
    this.searchInput = page.getByLabel('Search locations:')
  }

  async open () {
    await this.page.getByRole('button', { name: 'select a different location' }).click()
    await expect(this.dialog).toBeVisible()
  }

  async close () {
    await this.dialog.getByRole('button', { name: 'Close' }).click()
    await expect(this.dialog).toBeHidden()
  }

  async cancel () {
    await this.dialog.getByRole('button', { name: 'cancel' }).click()
  }

  async confirm () {
    await this.dialog.getByRole('button', { name: 'confirm' }).click()
    await expect(this.dialog).toBeHidden()
  }

  async search (term: string) {
    await this.searchInput.fill(term)
  }

  async selectResult (index = 0) {
    await this.page.locator('.o-search-location__result').nth(index)
      .click()
  }

  async selectMapType (label: string) {
    await this.dialog.getByLabel(label).click()
  }

  async clickFirstMapSegment () {
    await this.dialog.locator('.c-map__map path').first()
      .click()
  }

  async hoverFirstMapSegment () {
    await this.dialog.locator('.c-map__map path').first()
      .hover()
  }

  async getSearchValue () {
    return this.searchInput.inputValue()
  }

  isVisible () {
    return this.dialog.isVisible()
  }
}
