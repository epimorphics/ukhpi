<template lang='html'>
  <div class='o-data-view__js-options-statistics'>
    <span
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
        />
        {{ statistic.label }}
      </button>
    </span>
  </div>
</template>

<script>
import { SELECT_STATISTIC } from '../store/mutation-types';
import serverRoutes from '../store/server-routes.js.erb';

const MARKERS = [
  'Circle',
  'Diamond',
  'Square',
  'TriangleDown',
  'TriangleUp',
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
  },

  getters: {
  },

  mounted() {
    const store = this.$store;
    this.statistics = this.initialStatistics;

    this.initialStatistics.forEach((stat) => {
      store.commit(SELECT_STATISTIC, { slug: stat.slug, selected: stat.selected });
    });
  },

  methods: {
    /**
     * Handler for the event of the user clicking to select or deselect a statistic.
     * Actual state change happens by propagating a change to the Vuex store
     */
    onSelectStatistic(event) {
      const slug = event.toElement.attributes.getNamedItem('data-slug').value;
      const selected = this.isSelectedStatistic(slug);
      this.$store.commit(SELECT_STATISTIC, { slug, selected: !selected });
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
