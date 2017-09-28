import Vue from 'vue';
import DataView from './data-view.vue';

document.addEventListener('DOMContentLoaded', () => {
  const nodes = document.querySelectorAll('.o-data-view__vue-root');

  for (let i = 0; i < nodes.length; i += 1) {
    const node = nodes.item(i);
    new Vue(DataView).$mount(node);
  }
});
