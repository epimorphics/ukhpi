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
    await this.searchInput.pressSequentially(term)
  }

  async selectResult (index = 0) {
    await this.page.locator('.o-search-location__result').nth(index)
      .getByRole('button')
      .click()
  }

  async selectMapType (label: string) {
    await this.dialog.getByRole('radio', { name: label }).click()
  }

  async clickFirstMapSegment () {
    const path = this.dialog.locator('.c-map__map path').first()
    // eslint-disable-next-line playwright/no-force-option -- Leaflet SVG paths are perpetually redrawn and never pass stability checks
    await path.click({ force: true })
  }

  async hoverFirstMapSegment () {
    const path = this.dialog.locator('.c-map__map path').first()
    // eslint-disable-next-line playwright/no-force-option -- Leaflet SVG paths are perpetually redrawn and never pass stability checks
    await path.hover({ force: true })
  }

  async getSearchValue () {
    return this.searchInput.inputValue()
  }

  isVisible () {
    return this.dialog.isVisible()
  }
}
