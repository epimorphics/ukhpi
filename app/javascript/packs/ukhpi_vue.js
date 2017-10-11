import Vue from 'vue';
import ElementUI from 'element-ui';
import locale from 'element-ui/lib/locale/lang/en';
import Numeral from 'numeral';
import DataView from './data-view.vue';
import OptionsSelection from './components/options-selection.vue';
import bindExternalEvents from './lib/bind-external-events';

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
  const nodes = document.querySelectorAll('.o-data-view__vue-root');

  // add DateView components
  for (let i = 0; i < nodes.length; i += 1) {
    const node = nodes.item(i);
    new Vue(DataView).$mount(node);
  }

  // add options selection component
  const optionsNode = document.querySelector('.c-options-select');
  new Vue(OptionsSelection).$mount(optionsNode);

  bindExternalEvents();
});
