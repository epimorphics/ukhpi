import Vue from 'vue/dist/vue.esm'
import ElementUI from 'element-ui'
import locale from 'element-ui/lib/locale/lang/en'
import Numeral from 'numeral'
import * as Sentry from '@sentry/browser'
import * as Integrations from '@sentry/integrations'
import 'core-js/stable'
import 'regenerator-runtime/runtime'

import router from '../router/index.js.erb'
import store from '../store/index'

// Issue https://github.com/epimorphics/ukhpi/issues/169
// Add fix for IE Edge
import '../lib/ie-d3-fix'

// Use Element.IO
Vue.use(ElementUI, { locale })

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

document.addEventListener('DOMContentLoaded', () => {
  // Sentry.io logging
  Sentry.init({
    dsn: 'https://1150348b449a444bb3ac47ddd82b37c4@sentry.io/251669',
    integrations: [new Integrations.Vue({ Vue, attachProps: true })],
    release: window.ukhpi.version || 'unknown-version'
  })
  Sentry.configureScope(scope => {
    scope.setTag('app', 'ukhpi-js')
  })

  /* eslint-disable no-new */
  new Vue({
    router,
    store
  }).$mount('#application')
})
