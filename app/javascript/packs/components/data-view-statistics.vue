<template lang='html'>
  <div class='o-data-view__js-options-statistics'>
    <span
      v-for='(statistic, index) in statistics'
      :key='statistic.slug'
      class='o-data-view__js-options-statistics'>
      <a
        :data-slug='statistic.slug'
        href='#' @click='onSelectStatistic'>
        <span :class='selectedClassExpression(statistic, index)'>
        </span>
        {{ statistic.label }}
      </a>
    </span>
  </div>
</template>

<script>
import { SELECT_STATISTIC } from '../store/mutation-types';

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
    selectedClassExpression({ slug }, index) {
      const selected = this.isSelectedStatistic(slug);
      const graphColour = selected ? `v-graph-${index}` : '';
      return `o-statistic-option o-statistic-option__selected--${selected} ${graphColour}`;
    },
  },
};
</script>

<style lang='scss'>
</style>
