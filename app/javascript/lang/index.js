import Vue from 'vue/dist/vue.esm'
import VueI18n from 'vue-i18n'

Vue.use(VueI18n)

const localeEn = require('../../../config/locales/en.yml')
const localeCy = require('../../../config/locales/cy.yml')

export default new VueI18n({
  locale: 'en',
  messages: { ...localeEn, ...localeCy }
})
