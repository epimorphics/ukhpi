import Vue from 'vue';
import App from './app.vue';

document.addEventListener('DOMContentLoaded', () => {
  const nodes = document.querySelectorAll('.o-data-view__vue-root');

  for (let i = 0; i < nodes.length; i += 1) {
    const node = nodes.item(i);
    new Vue(App).$mount(node);
  }
});
