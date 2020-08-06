import Vue from 'vue/dist/vue.esm'
import VueI18n from 'vue-i18n'

Vue.use(VueI18n)

const localeEn = require('../../../config/locales/en.yml')
const localeCy = require('../../../config/locales/cy.yml')

// The locale is passed via the window.ukhpi structure
// directly from Rails
const currentLocale = window.ukhpi.locale || 'en'

export default new VueI18n({
  locale: currentLocale,
  messages: { ...localeEn, ...localeCy }
})
