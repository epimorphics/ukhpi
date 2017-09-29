<template lang="html">
  <div class='o-data-view__vue-root u-js-only'>
    <div class='o-data-view__js-options'>
      <data-view-location :initial-location='location'></data-view-location>
      <data-view-dates :initial-from-date='fromDate' :initial-to-date='toDate'></data-view-dates>

      <data-view-statistics :initial-statistics='theme.statistics'></data-view-statistics>
    </div>
  </div>

</template>

<script>
import kebabCase from 'kebab-case';
import DataViewLocation from './components/data-view-location.vue';
import DataViewDates from './components/data-view-dates.vue';
import DataViewStatistics from './components/data-view-statistics.vue';

export default {
  data: () => ({
    theme: null,
    indicator: null,
    location: null,
    fromDate: null,
    toDate: null,
  }),

  components: {
    DataViewLocation,
    DataViewDates,
    DataViewStatistics,
  },

  beforeMount() {
    const attrs = this.$el.attributes;

    for (let i = 0; i < attrs.length; i += 1) {
      const attr = attrs.item(i);

      if (attr.name.match(/^data-/)) {
        const name = kebabCase.reverse(attr.name.replace(/^data-/, ''));
        const value = JSON.parse(attr.value);
        this.$set(this, name, value);
      }
    }
  },
};
</script>

<style lang="scss">
</style>
