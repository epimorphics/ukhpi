import Vue from 'vue/dist/vue.esm'
import VueI18n from 'vue-i18n'

import localeEn from '../../../config/locales/en.yml'
import localeCy from '../../../config/locales/cy.yml'

Vue.use(VueI18n)

// The locale is passed via the window.ukhpi structure
// directly from Rails
const currentLocale = window.ukhpi.locale || 'en'

// Every Vue component will be able to access the current
// locale as `$locale`
if (!Object.prototype.hasOwnProperty.call(Vue, '$locale')) {
  Object.defineProperty(Vue.prototype, '$locale', {
    value: currentLocale,
    writable: false,
  })
}

export default new VueI18n({
  locale: currentLocale,
  messages: { ...localeEn, ...localeCy },
})
