<template lang='html'>
  <div>
    <options-selection />
    <compare-selection />
  </div>
</template>

<script>
import Vue from 'vue/dist/vue.esm';
import DataView from './data-view.vue';
import OptionsSelection from './options-selection.vue';
import CompareSelection from './compare-selection.vue';
import bindExternalEvents from '../lib/bind-external-events';

function locationButton(title) {
  return `<button type='button' class='el-button c-options-selection__button o-data-view__location'
         title='select a diffent location'>
         <span class='o-data-view__location-name'>${title}</span>
         <i class='fa fa-edit'></i></span></button>`;
}

export default {
  components: {
    OptionsSelection,
    CompareSelection,
  },

  mounted() {
    // location names should now be buttons not anchor elements
    let nodes = document.querySelectorAll('.o-data-view__location');
    for (let i = 0; i < nodes.length; i += 1) {
      const node = nodes.item(i);
      const locationName = node.querySelector('.o-data-view__location-name').innerHTML;
      node.outerHTML = locationButton(locationName);
    }

    // add DataView components
    nodes = document.querySelectorAll('.o-data-view__vue-root');
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
    Vue.nextTick(bindExternalEvents);
  },
};
</script>

<style lang='scss'>
</style>
