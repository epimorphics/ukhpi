<template lang="html">
  <div class='o-data-view__vue-root u-js-only'>
    <div class='o-data-view__js-options'>
      <data-view-location :initial-location='location'></data-view-location>
      <data-view-dates
        :initial-from-date='fromDate'
        :initial-to-date='toDate'
      >
      </data-view-dates>

      <data-view-statistics :initial-statistics='theme.statistics'></data-view-statistics>
    </div>
    <div class='o-data-view__data-display'>
      <data-view-table
        :statistics='theme.statistics'
        :indicator='indicator'
      >
      </data-view-table>
    </div>
  </div>

</template>

<script>
import kebabCase from 'kebab-case';
import DataViewLocation from './components/data-view-location.vue';
import DataViewDates from './components/data-view-dates.vue';
import DataViewStatistics from './components/data-view-statistics.vue';
import DataViewTable from './components/data-view-table.vue';
import store from './store/index';
import { INITIALISE } from './store/mutation-types';

export default {
  data: () => ({
    theme: null,
    indicator: null,
    location: null,
    fromDate: null,
    toDate: null,
    first: false,
  }),

  components: {
    DataViewLocation,
    DataViewDates,
    DataViewStatistics,
    DataViewTable,
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

  mounted() {
    this.checkStoreInitialised();
  },

  methods: {
    checkStoreInitialised() {
      // we only need this to happen once, so the page renderer sets a flag on
      // the first data-view component on the page
      if (this.first) {
        this.initialiseStore();
      }
    },

    initialiseStore() {
      this.$store.commit(INITIALISE, {
        location: this.location,
        fromDate: this.fromDate,
        toDate: this.toDate,
      });
    },
  },

  store,
};
</script>

<style lang="scss">
</style>
