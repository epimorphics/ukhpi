<template lang='html'>
  <select-location
    :dialog-visible='dialogVisible'
    :element-id='elementId'
    @update:dialog-visible='val => dialogVisible = val'
    :prompt='prompt'
    title='Choose another location'
    emit-event='additional-location-selected'
  ></select-location>
</template>

<script>
import SelectLocation from './select-location.vue';
import store from '../store/index';
import { SET_COMPARE_LOCATIONS } from '../store/mutation-types';
import bus from '../lib/event-bus';

export default {
  data: () => ({
    elementId: 'comparisonSelection',
    dialogVisible: false,
  }),

  computed: {
    prompt() {
      return 'Select an additional area to compare';
    },
  },

  components: {
    SelectLocation,
  },

  mounted() {
    bus.$on('select-comparison', this.onSelectComparison);
    bus.$on('additional-location-selected', this.onAdditionalLocation);
  },

  methods: {
    onSelectComparison() {
      this.dialogVisible = true;
    },

    onAdditionalLocation(location) {
      const newLocations = this.$store.state.compareLocations.concat([location]);
      this.$store.commit(SET_COMPARE_LOCATIONS, newLocations);
    },
  },

  store,
};
</script>

<style lang='css'>
</style>
