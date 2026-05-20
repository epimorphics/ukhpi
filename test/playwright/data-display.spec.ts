import { test, expect } from './fixtures/index'
import { DateRangeModal } from './fixtures/date-range-modal'

const SPECIFIC_QUERY_URL = 'browse?from=2020-10-01&to=2021-10-01'
const ALL_SECTIONS_OPEN_URL = 'browse?thm[]=property_type&thm[]=buyer_status&thm[]=funding_status&thm[]=property_status&in[]=avg&in[]=pac&in[]=pmc&in[]=hpi&in[]=vol'

test.describe('UKHPI data display', () => {
  test.describe('Query results default parameters', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto('browse')
      await page.getByRole('button', { name: 'select a different location' }).waitFor()
    })

    test('defaults to showing United Kingdom as location', async ({ page }) => {
      const selectDifferentLocationButton = page.getByRole('button', { name: 'select a different location' })
      await selectDifferentLocationButton.waitFor()
      await expect(selectDifferentLocationButton).toHaveText(/United Kingdom/i)
    })

    test('defaults to a date range ending at the latest available month', async ({ page }) => {
      await expect(page.getByRole('button', { name: /change start or end date/i })).toBeVisible()
    })

    test('defaults to a start date 12 months before the end date', async ({ page }) => {
      const modal = new DateRangeModal(page)
      await modal.open()
      const startValue = await modal.getStartValue()
      const endValue = await modal.getEndValue()
      await modal.cancel()
      const startParts = startValue.split('-')
      const endParts = endValue.split('-')
      const monthDiff = (Number(endParts[0]) - Number(startParts[0])) * 12 + (Number(endParts[1]) - Number(startParts[1]))
      expect(monthDiff).toBe(12)
    })
  })

  test.describe('Chart sections - section headings and quick links', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto('browse')
      await page.getByRole('button', { name: 'select a different location' }).waitFor()
    })

    test('Type of property section heading is visible', async ({ page }) => {
      await expect(page.getByRole('heading', { name: 'Type of property', exact: true })).toBeVisible()
    })

    test('quick link anchors to Type of property section', async ({ page }) => {
      await page.getByRole('link', { name: 'by property type' }).click()
      await expect(page).toHaveURL(/#property_type/)
    })

    test('Buyer status section heading is visible', async ({ page }) => {
      await expect(page.getByRole('heading', { name: 'Buyer status', exact: true })).toBeVisible()
    })

    test('quick link anchors to Buyer status section', async ({ page }) => {
      await page.getByRole('link', { name: 'by buyer status' }).click()
      await expect(page).toHaveURL(/#buyer_status/)
    })

    test('Funding status section heading is visible', async ({ page }) => {
      await expect(page.getByRole('heading', { name: 'Funding status', exact: true })).toBeVisible()
    })

    test('quick link anchors to Funding status section', async ({ page }) => {
      await page.getByRole('link', { name: 'by funding status' }).click()
      await expect(page).toHaveURL(/#funding_status/)
    })

    test('Property status section heading is visible', async ({ page }) => {
      await expect(page.getByRole('heading', { name: 'Property status', exact: true })).toBeVisible()
    })

    test('quick link anchors to Property status section', async ({ page }) => {
      await page.getByRole('link', { name: 'by property status' }).click()
      await expect(page).toHaveURL(/#property_status/)
    })
  })

  test.describe('Chart sections - Type of property', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(ALL_SECTIONS_OPEN_URL)
      await page.locator('.o-data-view--open').first()
        .waitFor()
    })

    for (const chart of [
      'Average price by type of property',
      'Percentage change (yearly) by type of property',
      'Percentage change (monthly) by type of property',
      'House price index by type of property',
      'Sales volume by type of property',
    ]) {
      test(`section for '${chart}' shows a chart when expanded`, async ({ page }) => {
        const section = page.locator('.o-data-view--open').filter({ hasText: chart })
          .first()
        await expect(section.locator('svg').first()).toBeVisible()
      })
    }
  })

  test.describe('Chart sections - Buyer status', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(ALL_SECTIONS_OPEN_URL)
      await page.locator('.o-data-view--open').first()
        .waitFor()
    })

    for (const chart of [
      'Average price by buyer status',
      'Percentage change (yearly) by buyer status',
      'Percentage change (monthly) by buyer status',
      'House price index by buyer status',
    ]) {
      test(`section for '${chart}' shows a chart when expanded`, async ({ page }) => {
        const section = page.locator('.o-data-view--open').filter({ hasText: chart })
          .first()
        await expect(section.locator('svg').first()).toBeVisible()
      })
    }
  })

  test.describe('Chart sections - Funding status', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(ALL_SECTIONS_OPEN_URL)
      await page.locator('.o-data-view--open').first()
        .waitFor()
    })

    for (const chart of [
      'Average price by funding status',
      'Percentage change (yearly) by funding status',
      'Percentage change (monthly) by funding status',
      'House price index by funding status',
      'Sales volume by funding status',
    ]) {
      test(`section for '${chart}' shows a chart when expanded`, async ({ page }) => {
        const section = page.locator('.o-data-view--open').filter({ hasText: chart })
          .first()
        await expect(section.locator('svg').first()).toBeVisible()
      })
    }
  })

  test.describe('Chart sections - Property status', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(ALL_SECTIONS_OPEN_URL)
      await page.locator('.o-data-view--open').first()
        .waitFor()
    })

    for (const chart of [
      'Average price by property status',
      'Percentage change (yearly) by property status',
      'Percentage change (monthly) by property status',
      'House price index by property status',
      'Sales volume by property status',
    ]) {
      test(`section for '${chart}' shows a chart when expanded`, async ({ page }) => {
        const section = page.locator('.o-data-view--open').filter({ hasText: chart })
          .first()
        await expect(section.locator('svg').first()).toBeVisible()
      })
    }
  })

  test.describe('View data graph tab', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto('browse')
      await page.locator('.o-data-view--open').first()
        .waitFor()
    })

    test('first section is expanded by default showing a chart', async ({ page }) => {
      await expect(page.locator('.o-data-view--open').first()
        .locator('svg')
        .first()).toBeVisible()
    })

    test('tabbed navigation defaults to See data graph tab', async ({ page }) => {
      const activeTab = page.locator('.el-tabs__item.is-active').first()
      await expect(activeTab).toHaveText('See data graph')
    })

    test('line graph is visible in the open section', async ({ page }) => {
      await expect(page.locator('.o-data-view--open svg').first()).toBeVisible()
    })

    test('line graph defaults to showing All property types', async ({ page }) => {
      const checkbox = page.locator('.o-data-view--open').first()
        .getByRole('checkbox', { name: /All property types/i })
      await expect(checkbox).toBeChecked()
    })

    test('property type checkboxes add data points to the line graph', async ({ page }) => {
      const section = page.locator('.o-data-view--open').first()
      await section.locator('input[data-slug="det"]').click()
      await expect(section.locator('svg').first()).toBeVisible()
    })

    test('clicking the magnifying glass icon opens the graph in a modal', async ({ page }) => {
      await page.locator('.o-data-view--open svg text').filter({ hasText: '' })
        .first()
        .click()
      await expect(page.getByRole('dialog')).toBeVisible()
    })
  })

  test.describe('View data table tab', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(SPECIFIC_QUERY_URL)
      await page.locator('.o-data-view--open').first()
        .waitFor()
      await page.getByRole('tab', { name: 'See data table' }).first()
        .click()
    })

    test('See data table tab shows tabular data', async ({ page }) => {
      await expect(page.locator('.o-data-view--open .o-data-view__table').first()).toBeVisible()
    })

    test('table has a row for Oct 2020', async ({ page }) => {
      await expect(
        page.locator('.o-data-view--open .o-data-view__table').first()
          .getByRole('cell', { name: /Oct 2020/i }),
      ).toBeVisible()
    })

    test('property type checkboxes add data columns to the table', async ({ page }) => {
      const table = page.locator('.o-data-view--open .o-data-view__table').first()
      const initialCols = await table.locator('thead th').count()
      await page.locator('.o-data-view--open').first()
        .locator('input[data-slug="det"]')
        .click()
      await expect(table.locator('thead th').nth(initialCols)).toBeVisible()
    })

    test('print this table opens a new browser window', async ({ page, context }) => {
      const [newPage] = await Promise.all([
        context.waitForEvent('page'),
        page.locator('.o-data-view--open .o-print-action').first()
          .click(),
      ])
      await newPage.waitForLoadState()
      expect(newPage.url()).toMatch(/print/)
      await newPage.close()
    })
  })

  test.describe('Download this data tab', () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(SPECIFIC_QUERY_URL)
      await page.locator('.o-data-view--open').first()
        .waitFor()
      await page.getByRole('tab', { name: 'Download this data' }).first()
        .click()
    })

    test('Download this data tab shows download links', async ({ page }) => {
      await expect(page.locator('.o-data-view-download').first()).toBeVisible()
    })

    test('download CSV/spreadsheet link is present', async ({ page }) => {
      await expect(
        page.locator('.o-data-view-download').first()
          .getByRole('link', { name: /download CSV\/spreadsheet/i })
          .first(),
      ).toBeVisible()
    })

    test('download JSON link is present', async ({ page }) => {
      await expect(
        page.locator('.o-data-view-download').first()
          .getByRole('link', { name: /download JSON/i })
          .first(),
      ).toBeVisible()
    })

    test('try the SPARQL query link is present and points to SPARQL console', async ({ page }) => {
      const sparqlLink = page.locator('.o-data-view-download').first()
        .getByRole('link', { name: /try the SPARQL query/i })
      await expect(sparqlLink).toBeVisible()
      const href = await sparqlLink.getAttribute('href')
      expect(href).toMatch(/qonsole/)
    })
  })
})
