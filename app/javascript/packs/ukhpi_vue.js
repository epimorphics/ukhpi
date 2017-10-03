import Vue from 'vue';
import ElementUI from 'element-ui';
import Numeral from 'numeral';
import DataView from './data-view.vue';
import bindExternalEvents from './lib/bind-external-events';

Vue.use(ElementUI);

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
  const nodes = document.querySelectorAll('.o-data-view__vue-root');

  for (let i = 0; i < nodes.length; i += 1) {
    const node = nodes.item(i);
    new Vue(DataView).$mount(node);
  }

  bindExternalEvents();
});
