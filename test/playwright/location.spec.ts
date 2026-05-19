import { test, expect } from './fixtures/index'
import { LocationModal } from './fixtures/location-modal'

test.describe('Location modal', () => {
  let modal: LocationModal

  test.beforeEach(async ({ page }) => {
    await page.goto('browse')
    await page.getByRole('button', { name: 'select a different location' }).waitFor()
    modal = new LocationModal(page)
  })

  test.describe('Map view', () => {
    test('location edit button opens modal with map', async ({ page }) => {
      await modal.open()
      await expect(page.locator('.c-map')).toBeVisible()
    })

    test('map zoom in and zoom out buttons are present', async ({ page }) => {
      await modal.open()
      await expect(page.getByRole('button', { name: 'Zoom in' })).toBeVisible()
      await expect(page.getByRole('button', { name: 'Zoom out' })).toBeVisible()
    })

    test('close icon dismisses the modal', async () => {
      await modal.open()
      await modal.close()
    })
  })

  test.describe('Filter by keyword — select from list', () => {
    test('typing a partial term shows a dropdown of suggestions', async ({ page }) => {
      await modal.open()
      await modal.search('Bi')
      await expect(page.locator('.o-search-location__results').first()).toBeVisible()
      await expect(page.locator('.o-search-location__result').first()).toBeVisible()
    })

    test('selecting a result and confirming sets the location', async ({ page }) => {
      await modal.open()
      await modal.search('Bi')
      await modal.selectResult(0)
      await modal.confirm()
      const locationBtn = page.getByRole('button', { name: 'select a different location' })
      await expect(locationBtn).not.toHaveText(/England$/)
    })

    test('location modal can be reopened after selection', async ({ page }) => {
      await modal.open()
      await modal.search('Bi')
      await modal.selectResult(0)
      await modal.confirm()
      await modal.open()
      await expect(page.locator('.c-map')).toBeVisible()
    })
  })

  test.describe('Filter by keyword — type full location name', () => {
    test('typing a full location name and pressing enter sets the location', async ({ page }) => {
      await modal.open()
      await modal.search('London')
      await page.getByLabel('Search locations:').press('Enter')
      await expect(page.locator('.el-dialog').filter({ hasText: 'Choose a different region or location' })).toBeHidden()
      await expect(
        page.getByRole('button', { name: /select a different location/ }),
      ).toContainText(/London/i)
    })
  })

  test.describe('Filter by map region', () => {
    test.beforeEach(async () => {
      await modal.open()
    })

    test('Countries radio button can be selected', async ({ page }) => {
      await modal.selectMapType('Countries')
      await expect(page.getByLabel('Countries')).toBeChecked()
    })

    test('Local authorities radio button can be selected', async ({ page }) => {
      await modal.selectMapType('Local authorities')
      await expect(page.getByLabel('Local authorities')).toBeChecked()
    })

    test('Regions of England radio button can be selected', async ({ page }) => {
      await modal.selectMapType('Regions of England')
      await expect(page.getByLabel('Regions of England')).toBeChecked()
    })

    test('Counties of England radio button can be selected', async ({ page }) => {
      await modal.selectMapType('Counties of England')
      await expect(page.getByLabel('Counties of England')).toBeChecked()
    })

    test('hovering a map segment shows a tooltip', async ({ page }) => {
      await modal.hoverFirstMapSegment()
      await expect(page.locator('.leaflet-tooltip')).toBeVisible()
    })

    test('clicking a map segment populates the search field', async () => {
      await modal.clickFirstMapSegment()
      const value = await modal.getSearchValue()
      expect(value.length).toBeGreaterThan(0)
    })

    test('confirming a map-selected region sets the location', async ({ page }) => {
      await modal.clickFirstMapSegment()
      await modal.confirm()
      const locationBtn = page.getByRole('button', { name: 'select a different location' })
      await expect(locationBtn).toBeVisible()
    })
  })
})
