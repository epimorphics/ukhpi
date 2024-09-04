<template lang='html'>
  <div class='o-data-view__js-options-statistics'>
    <label v-for='(statistic, index) in statistics'
      :key='statistic.slug'
      class="checkbox-container">
      <input
        type="checkbox"
        :name='statistic.label'
        :data-slug='statistic.slug'
        @change='onSelectStatistic'
        :checked='isSelectedStatistic(statistic.slug)'
        @keydown.enter="onSelectStatistic"
      />
        <img
          :src='imageSrcPath(index, false)'
          :srcset='imageSrcPath(index, true)'
          :alt='`marker image for ${statistic.label}`'
        />
        {{ statistic.label }}
    </label>
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

  mounted() {
    this.initStatistics();
  },

  methods: {
    initStatistics() {
      if (this.statistics !== this.initialStatistics) {
        this.statistics = this.initialStatistics;
      }
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
    
    onSelectStatistic(event) {
      const slug = event.target.getAttribute('data-slug');
      const selected = this.isSelectedStatistic(slug);
      this.$store.commit(SELECT_STATISTIC, { slug, isSelected: !selected });
    },

    isSelectedStatistic(slug) {
      return this.$store.state.selectedStatistics[slug];
    },

    imageSrcPath(index, svg) {
      const imageRoot = MARKERS[index];
      const imagePathKey = `marker${imageRoot}${svg ? 'Svg' : ''}`;
      return serverRoutes[imagePathKey];
    },
  },
};
</script>

<style lang='scss'>
</style>
