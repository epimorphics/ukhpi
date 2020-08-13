<template lang='html'>
  <select-location
    :dialog-visible='dialogVisible'
    :element-id='elementId'
    @update:dialog-visible='val => dialogVisible = val'
    :prompt='prompt'
    title='Choose another location'
    emit-event='compare-location-selected'
  ></select-location>
</template>

<script>
import SelectLocation from './select-location.vue';
import store from '../store/index';
import bus from '../lib/event-bus';

export default {
  data: () => ({
    elementId: 'comparisonSelection',
    dialogVisible: false,
    statistic: null,
    indicator: null,
  }),

  computed: {
    selectedLocation() {
      return this.$store.state.location;
    },

    prompt() {
      const label = this.selectedLocation ? this.selectedLocation.labels[this.$locale] : '';
      return this.$t('js.compare.action_prompt', { location: label });
    }
  },

  components: {
    SelectLocation,
  },

  mounted() {
    bus.$on('select-comparison', this.onSelectComparison);
    bus.$on('compare-location-selected', this.onCompareLocationSelected);
  },

  methods: {
    onSelectComparison({ statistic, indicator }) {
      this.indicator = indicator;
      this.statistic = statistic;
      this.dialogVisible = true;
    },

    onCompareLocationSelected(location) {
      const gss0 = this.selectedLocation.gss;
      const gss1 = location.gss;
      const from = this.$store.state.fromDate;
      const to = this.$store.state.toDate;
      const ind = this.indicator.slug;
      const st = this.statistic.slug;
      const path = document.location.pathname.replace(/browse/, 'compare');

      document.location = `${path}?from=${from}&to=${to}&in=${ind}&st=${st}&location[]=${gss0}&location[]=${gss1}&lang=${this.$locale}`;
    },
  },

  store,
};
</script>

<style lang='css'>
</style>
