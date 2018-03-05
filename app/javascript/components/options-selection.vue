<template lang='html'>
  <div class='c-options-selection'>
    <data-view-location :element-id='elementId'></data-view-location>
    for <data-view-dates></data-view-dates>
    <data-view-graph-zoomed></data-view-graph-zoomed>
  </div>
</template>

<script>
import DataViewLocation from './data-view-location.vue';
import DataViewDates from './data-view-dates.vue';
import DataViewGraphZoomed from './data-view-graph-zoomed.vue';
import store from '../store/index';

export default {
  data: () => ({
    elementId: 'optionsSelection',
  }),

  components: {
    DataViewLocation,
    DataViewDates,
    DataViewGraphZoomed,
  },

  store,
};
</script>

<style lang='css'>
</style>
