<template lang='html'>
  <div class='o-data-view__js-options-statistics'>
    <span
      v-for='(statistic, index) in statistics'
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
import bus from '../lib/event-bus';

export default {
  data: () => ({
    statistics: {},
  }),

  props: [
    'initialStatistics',
  ],

  mounted() {
    this.statistics = this.initialStatistics;
    bus.$on('statistic-selected', this.onStatisticSelected);
  },

  methods: {
    /**
     * Handler for the event of the user clicking to select or deselect a statistic.
     * Actual state change happens by propagating an event to all DataViewStatistic
     * components.
     */
    onSelectStatistic(event) {
      const slug = event.toElement.attributes.getNamedItem('data-slug').value;
      const statistic = this.findStatistic(slug);
      bus.$emit('statistic-selected', { slug, selected: !statistic.selected });
    },

    /**
     * Event handler for the event that the given statistic has been selected or
     * deselected in every DataView that contains it.
     */
    onStatisticSelected(event) {
      const stat = this.findStatistic(event.slug);
      if (stat) {
        stat.selected = event.selected;
      }
    },

    findStatistic(slug) {
      return this.statistics.find(stat => stat.slug === slug);
    },

    /** @return The CSS class for the status indicator */
    selectedClassExpression({ selected }, index) {
      const graphColour = selected ? `v-graph-${index}` : '';
      return `o-statistic-option o-statistic-option__selected--${selected} ${graphColour}`;
    },
  },
};
</script>

<style lang='scss'>
</style>
