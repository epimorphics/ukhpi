import Vue from 'vue/dist/vue.esm'
import ElementUI from 'element-ui'
import localeEn from 'element-ui/lib/locale/lang/en'
import localeCy from '../lang/element-ui-cy'
import Numeral from 'numeral'
import * as Sentry from '@sentry/browser'
import * as Integrations from '@sentry/integrations'
import 'core-js/stable'
import 'regenerator-runtime/runtime'
import moment from 'moment'

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
Vue.use(ElementUI, { locale: i18n.locale === 'en' ? localeEn : localeCy })

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

moment.locale(i18n.locale)

document.addEventListener('DOMContentLoaded', () => {
  if (process.env.NODE_ENV === 'production') {
    // Sentry.io logging
    Sentry.init({
      dsn: 'https://1150348b449a444bb3ac47ddd82b37c4@sentry.io/251669',
      integrations: [new Integrations.Vue({ Vue, attachProps: true })],
      release: window.ukhpi.version || 'unknown-version'
    })
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
