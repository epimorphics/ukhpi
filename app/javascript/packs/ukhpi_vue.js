import Vue from 'vue/dist/vue.esm'
import ElementUI from 'element-ui'
import localeEn from 'element-ui/lib/locale/lang/en'
import localeElementCy from '../lang/element-ui-cy'
import localeD3Cy from '../lang/d3-timeformat-cy.json'
import Numeral from 'numeral'
import * as Sentry from '@sentry/browser'
import * as Integrations from '@sentry/integrations'
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
import i18n from 'lang'

Vue.use(VueI18n)

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
  // Sentry.io logging
  Sentry.init({
    dsn: 'https://1150348b449a444bb3ac47ddd82b37c4@sentry.io/251669',
    debug: process.env.NODE_ENV === 'development',
    environment: process.env.NODE_ENV,
    integrations: [
      new Integrations.Vue({ Vue, attachProps: true })
    ],
    release: window.ukhpi.version || '1.0.0',
    ignoreErrors: ['Non-Error promise rejection captured']
  })

  if (process.env.NODE_ENV === 'production') {
    Sentry.configureScope(scope => {
      scope.setTag('app', 'ukhpi-js')
    })
  }

  /* eslint-disable no-new */
  new Vue({
    router,
    store,
    i18n
  }).$mount('#application')
})
