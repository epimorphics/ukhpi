import 'babel-polyfill';
import Vue from 'vue';
import ElementUI from 'element-ui';
import locale from 'element-ui/lib/locale/lang/en';
import Numeral from 'numeral';

import router from './router/index.js.erb';
import store from './store/index';

// Use Element.IO
Vue.use(ElementUI, { locale });

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
});
Numeral.locale('gb');

document.addEventListener('DOMContentLoaded', () => {
  /* eslint-disable no-new */
  new Vue({
    router,
    store,
  }).$mount('#application');
});
