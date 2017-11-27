<template lang='html'>
  <div>
    <options-selection />
    <compare-selection />
  </div>
</template>

<script>
import Vue from 'vue';
import DataView from './data-view.vue';
import OptionsSelection from './options-selection.vue';
import CompareSelection from './compare-selection.vue';
import bindExternalEvents from '../lib/bind-external-events';

export default {
  components: {
    OptionsSelection,
    CompareSelection,
  },

  mounted() {
    const nodes = document.querySelectorAll('.o-data-view__vue-root');

    // add DataView components
    for (let i = 0; i < nodes.length; i += 1) {
      const node = nodes.item(i);
      new Vue(DataView).$mount(node);
    }

    // add options selection component
    // const optionsNode = document.querySelector('.c-options-select');
    // new Vue(OptionsSelection).$mount(optionsNode);
    //
    // // add comparison selection component
    // const compareNode = document.querySelector('.c-compare-select');
    // new Vue(CompareSelection).$mount(compareNode);

    bindExternalEvents();
  },
};
</script>

<style lang='scss'>
</style>
