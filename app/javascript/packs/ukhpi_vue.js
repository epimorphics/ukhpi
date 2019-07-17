import '@babel/polyfill';
import Vue from 'vue/dist/vue.esm';
import ElementUI from 'element-ui';
import locale from 'element-ui/lib/locale/lang/en';
import Numeral from 'numeral';
import Raven from 'raven-js';
import RavenVue from 'raven-js/plugins/vue';

import router from '../router/index.js.erb';
import store from '../store/index';

// Issue https://github.com/epimorphics/ukhpi/issues/169
// Add fix for IE Edge
import '../lib/ie-d3-fix';

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
  // Sentry.io logging
  Raven
    .config('https://1150348b449a444bb3ac47ddd82b37c4@sentry.io/251669', {
      environment: window.ukhpi.environment,
    })
    .addPlugin(RavenVue, Vue)
    .install();

  /* eslint-disable no-new */
  new Vue({
    router,
    store,
  }).$mount('#application');
});
