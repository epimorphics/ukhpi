<template lang='html'>
  <div class='o-data-view__js-options-statistics'>
    <div v-for='(statistic, index) in statistics'
      :key='statistic.slug' class="checkbox-container">
      <input type="checkbox" :name='`${statistic.label}`' @click='onSelectStatistic' :data-slug='statistic.slug'>
      <label :for='`${statistic.label}`'>{{ statistic.label }}</label>
    </div>

    <!-- <span
      v-for='(statistic, index) in statistics'
      :key='statistic.slug'
      class='o-data-view__js-options-statistics'>
      <button
        :data-slug='statistic.slug'
        @click='onSelectStatistic'
      >
        <img
          :src='imageSrcPath(statistic, index, false)'
          :srcset='imageSrcPath(statistic, index, true)'
          :alt='`marker image for ${statistic.label}`'
        />
        {{ statistic.label }}
      </button>
    </span> -->
  </div>
</template>

<script>
import { SELECT_STATISTIC } from '../store/mutation-types';
import serverRoutes from '../store/server-routes.js.erb';

const MARKERS = [
  'Circle',
  'Diamond',
  'Square',
  'Star',
  'Triangle',
];

export default {
  data: () => ({
    statistics: [],
  }),

  props: {
    initialStatistics: {
      type: Array,
      required: true,
    },
    zoom: {
      type: Boolean,
      required: true,
    },
  },

  getters: {
  },

  mounted() {
    this.initStatistics();
  },

  watch: {
    initialStatistics() {
      this.initStatistics();
    },
  },

  methods: {
    initStatistics() {
      this.statistics = this.initialStatistics;
      if (!this.zoom) {
        this.syncSelectedStatisticsToStore();
      }
    },

    syncSelectedStatisticsToStore() {
      const store = this.$store;
      this.initialStatistics.forEach((stat) => {
        store.commit(SELECT_STATISTIC, { slug: stat.slug, isSelected: stat.isSelected });
      });
    },

    /**
     * Handler for the event of the user clicking to select or deselect a statistic.
     * Actual state change happens by propagating a change to the Vuex store.
     * Allows the click-target to be embedded within the button element, by walking
     * up the DOM tree until we find the element with the statistic slug.
     */
    onSelectStatistic(event) {
      let slug;
      let { target } = event;
      do {
        slug = target.attributes.getNamedItem('data-slug');
        target = target.parentElement;
      } while (!slug);

      const selected = this.isSelectedStatistic(slug.value);
      this.$store.commit(SELECT_STATISTIC, { slug: slug.value, isSelected: !selected });
    },

    findStatistic(slug) {
      return this.statistics.find(stat => stat.slug === slug);
    },

    isSelectedStatistic(slug) {
      return this.$store.state.selectedStatistics[slug];
    },

    /** @return The CSS class for the status indicator */
    imageSrcPath({ slug }, index, svg) {
      const selected = this.isSelectedStatistic(slug);
      const imageRoot = selected ? MARKERS[index] : 'SquareWhite';
      const imagePathKey = `marker${imageRoot}${svg ? 'Svg' : ''}`;
      return serverRoutes[imagePathKey];
    },
  },
};
</script>

<style lang='scss'>
</style>
