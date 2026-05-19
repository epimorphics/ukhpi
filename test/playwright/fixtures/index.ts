import { test as base, expect } from '@playwright/test'

// Pre-set the cookie consent cookie before page scripts run so the banner never appears.
// cookie.js checks for `hmlr_cookie_policy` on window.onload — if present it skips the banner.
export const test = base.extend({
  page: async ({ page }, use) => {
    await page.addInitScript(() => {
      const expires = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toUTCString()
      document.cookie = `hmlr_cookie_policy=${JSON.stringify({ analytics: false })};expires=${expires};path=/`
    })
    await use(page)
  },
})

export { expect }
