<template lang='html'>
  <div class='o-data-view__graph'>
    <svg :id='graphElementId'></svg>
  </div>
</template>

<script>
import Moment from 'moment';
import drawGraph from '../presenters/data-graph';

export default {
  props: {
    indicator: {
      required: false,
      type: Object,
    },
    theme: {
      required: true,
      type: Object,
    },
    elementId: {
      required: true,
      type: String,
    },
  },

  computed: {
    graphElementId() {
      return `${this.elementId}-graph`;
    },

    /** The data projection is the slice of the query results matching the statistics
     * in this theme. It updates automatically when the query results change. */
    dataProjection() {
      return this.$store.state.queryResults &&
        this.$store.state.queryResults.projection(this.indicator, this.theme);
    },

    selectedStatistics() {
      return this.$store.state.selectedStatistics;
    },

    fromMoment() {
      return Moment(this.$store.state.fromDate.date);
    },

    toMoment() {
      return Moment(this.$store.state.toDate.date);
    },

    /** @return The duration of the selected dates, in months */
    period() {
      return Math.ceil(this.toMoment.diff(this.fromMoment, 'months', true));
    },

    /** @return The date range for the selected dates */
    dateRange() {
      return [
        this.fromMoment.startOf('month').toDate(),
        this.toMoment.endOf('month').toDate(),
      ];
    },
  },

  watch: {
    dataProjection() {
      this.updateGraph();
    },

    selectedStatistics() {
      this.updateGraph();
    },
  },

  methods: {
    updateGraph() {
      if (this.dataProjection && this.isVisible(this.graphElementId)) {
        this.$nextTick(this.redrawGraph);
      }
    },

    redrawGraph() {
      drawGraph(
        this.dataProjection,
        {
          dateRange: this.dateRange,
          elementId: this.graphElementId,
          indicatorId: this.indicator ? this.indicator.root_name : 'salesVolume',
          period: this.period,
          selectedStatistics: this.selectedStatistics,
          theme: this.theme,
        },
      );
    },

    isVisible(id) {
      const elem = document.getElementById(id);
      return !!(elem.offsetWidth || elem.offsetHeight || elem.getClientRects().length);
    },
  },
};
</script>

<style lang='scss'>
.o-data-view__graph svg {
  width: 100%;
  height: 100%;
}

.line {
  fill: none;
  stroke-width: 2px;
}
</style>
