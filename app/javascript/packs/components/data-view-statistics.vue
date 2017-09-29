<template lang='html'>
  <div class='o-data-view__js-options-statistics'>
    <span
      v-for='statistic in statistics'
      class='o-data-view__js-options-statistics'>
      <span :class='"o-statistic o-statistic__selected--" + statistic.selected'>
      </span>
      <a
        :data-slug='statistic.slug'
        href='#' @click='onSelectStatistic'>
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
  },
};
</script>

<style lang='scss'>
.o-statistic {
  height: 15px;
  width: 15px;
  border: 1px solid black;

  display: inline-block;

  &.o-statistic__selected--true {
    background-color: blue;
  }
}
</style>
