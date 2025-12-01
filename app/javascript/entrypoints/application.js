import Vue from 'vue/dist/vue.esm'
import * as Sentry from '@sentry/vue'
import ElementUI from 'element-ui'
import localeEn from 'element-ui/lib/locale/lang/en'
import localeElementCy from '@/lang/element-ui-cy'
import localeD3Cy from '@/lang/d3-timeformat-cy.json'
import Numeral from 'numeral'
import 'core-js/stable'
import 'regenerator-runtime/runtime'
import moment from 'moment'
import { timeFormatDefaultLocale } from 'd3-time-format'

import router from '@/router/index.js'
import store from '@/store/index'

import getAppVersion from '@/lib/app_version'

// set up internationalization support
import VueI18n from 'vue-i18n'
import i18n from '@/lang'

const currentAppRelease = window.ukhpi.version || getAppVersion()

const currentEnvironment = import.meta.env.MODE || 'production' // fallback to production for safety

if (currentEnvironment === 'development') {
  console.debug('Vite ⚡️ Rails')

  console.debug(`Organisation: ${import.meta.env.SENTRY_ORG}`)
  console.debug(`Project: ${import.meta.env.SENTRY_PROJECT}`)
  console.debug(`Rails environment: ${import.meta.env.RAILS_ENV}`)
  console.debug(`Node environment: ${import.meta.env.MODE}`)
  console.debug(`HMLR UKHPI Environment: ${import.meta.env.SENTRY_ENVIRONMENT}`)
  console.debug(`HMLR UKHPI Version: ${currentAppRelease}`)
  console.debug(`Log Level: ${import.meta.env.LOG_LEVEL}`)
  console.debug(`Sentry Enabled: ${import.meta.env.SENTRY_ENABLED}`)

  console.debug('Visit the guide for more information: https://vite-ruby.netlify.app/guide/rails')

  console.warn('Not in production, skipping Sentry initialisation')
  console.debug('Development mode detected, enabling Vue devtools')
  Vue.config.devtools = true
} else {
  Vue.config.devtools = true
  if (import.meta.env.SENTRY_ENABLED) {
    // This sets the sample rate to be 100% while in development
    // and samples at a lower rate of 10% when in production
    const sessionSampleRate = currentEnvironment.includes('dev') ? 1.0 : 0.1
    // If we're not already sampling the entire session, change the error
    // sample rate to 100% when sampling sessions where errors occur.
    const errorSampleRate = currentEnvironment.includes('prod') ? 1.0 : 0.1

    // Register Sentry error tracking with Vue
    Sentry.init({
      Vue,
      debug: currentEnvironment.includes('dev'),
      dsn: import.meta.env.SENTRY_API_KEY,
      enabled: !currentEnvironment.includes('dev'),
      environment: currentEnvironment,
      ignoreErrors: ['Non-Error promise rejection captured'],
      initialScope: {
        tags: { app: 'ukhpi-js' },
      },
      integrations: [Sentry.replayIntegration()],
      release: `${currentAppRelease}`,
      // Session Replay set by current MODE env variable:
      replaysSessionSampleRate: sessionSampleRate,
      replaysOnErrorSampleRate: errorSampleRate,
      telemetry: {
        tracesSampleRate: currentEnvironment.includes('dev') ? 1.0 : 0.1,
        tracePropagationTargets: ['localhost', 'https://landregistry.gov.uk/app/ukhpi'],
      },
    })

    const sentryTags = {
      app: 'ukhpi-js',
      band: import.meta.env.SENTRY_BAND || null,
      enabled: import.meta.env.SENTRY_ENABLED || null,
      hostname: import.meta.env.SENTRY_HOSTNAME || null,
    }
    sentryTags.each((value, key) => {
      if (value !== null) { // Only set tags that are not null
        Sentry.setTag(key, value)
      }
    })
  }
}

// Set up the Vue app
Vue.use(VueI18n)

// Use Element.IO
Vue.use(ElementUI, { locale: i18n.locale === 'en' ? localeEn : localeElementCy })

// locale settings
Numeral.register('locale', 'gb', {
  delimiters: {
    thousands: ',',
    decimal: '.',
  },
  currency: {
    symbol: '£',
  },
  ordinal: () => '',
})
Numeral.locale('gb')

// other i18n settings: moment.js
moment.locale(i18n.locale)

// other i18n settings: D3.js
if (i18n.locale === 'cy') {
  timeFormatDefaultLocale(localeD3Cy)
}

const mountVueApp = () => {
  // This is the main entry point for the Vue app
  new Vue({
    i18n,
    store,
    router,
  }).$mount('#application')
}

/**
 * Mount the Vue app when the DOM is ready.
 * This ensures that the app is only mounted after the DOM has been fully loaded.
 */
if (document.readyState === 'loading') {
  // Loading hasn't finished yet
  document.addEventListener('DOMContentLoaded', mountVueApp)
} else {
  // DOMContentLoaded has already fired
  mountVueApp()
}
