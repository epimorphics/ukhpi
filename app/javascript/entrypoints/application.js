import * as Sentry from '@sentry/vue'
import dotenv from 'dotenv'
import Vue from 'vue/dist/vue.esm'
import ElementUI from 'element-ui'
import localeEn from 'element-ui/lib/locale/lang/en'
import localeElementCy from '../lang/element-ui-cy'
import localeD3Cy from '@/lang/d3-timeformat-cy.json'
import Numeral from 'numeral'
import 'core-js/stable'
import 'regenerator-runtime/runtime'
import moment from 'moment'
import { timeFormatDefaultLocale } from 'd3-time-format'

import router from '../router/index.js.erb'
import store from '../store/index'

// Issue https://github.com/epimorphics/ukhpi/issues/169
// Add fix for IE Edge
import '../lib/ie-d3-fix'

// set up internationalization support
import VueI18n from 'vue-i18n'
import i18n from '../lang'

const currentAppRelease = window.ukhpi.version // || await getAppVersion()

console.debug('Vite ⚡️ Rails')

console.debug(`Organisation: ${import.meta.env.SENTRY_ORG}`)
console.debug(`Project: ${import.meta.env.SENTRY_PROJECT}`)
console.debug(`Rails environment: ${import.meta.env.RAILS_ENV}`)
console.debug(`Node environment: ${import.meta.env.MODE}`)
console.debug(`FSA Alerts Environment: ${import.meta.env.FSA_ALERTS_ENVIRONMENT}`)
console.debug(`FSA Alerts Version: ${currentAppRelease}`)
console.debug(`Log Level: ${import.meta.env.LOG_LEVEL}`)

console.debug('Visit the guide for more information: https://vite-ruby.netlify.app/guide/rails')

const currentEnvironment = import.meta.env.MODE || 'production' // fallback to production for safety
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
  dsn: 'https://1150348b449a444bb3ac47ddd82b37c4@sentry.io/251669',
  environment: currentEnvironment,
  release: `${currentAppRelease}`,
  ignoreErrors: ['Non-Error promise rejection captured'],
  integrations: [
    Sentry.replayIntegration()
  ],
  // Session Replay set by current MODE env variable:
  replaysSessionSampleRate: sessionSampleRate,
  replaysOnErrorSampleRate: errorSampleRate
})

if (currentEnvironment === 'production') {
  Sentry.configureScope(scope => {
    scope.setTag('app', 'ukhpi-js')
  })
}

/* Load environment variables from .env.local and .env */
if (currentEnvironment === 'development') {
  dotenv.config({ path: '.env.local' })
}

Vue.use(VueI18n)
Vue.config.devtools = true

// Use Element.IO
Vue.use(ElementUI, { locale: i18n.locale === 'en' ? localeEn : localeElementCy })

// locale settings
Numeral.register('locale', 'gb', {
  delimiters: {
    thousands: ',',
    decimal: '.'
  },
  currency: {
    symbol: '£'
  },
  ordinal: () => ''
})
Numeral.locale('gb')

// other i18n settings: moment.js
moment.locale(i18n.locale)

// other i18n settings: D3.js
if (i18n.locale === 'cy') {
  timeFormatDefaultLocale(localeD3Cy)
}

document.addEventListener('DOMContentLoaded', () => {
  /* eslint-disable no-new */
  new Vue({
    router,
    store,
    i18n
  }).$mount('#application')
})
