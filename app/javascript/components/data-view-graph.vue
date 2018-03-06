<template lang='html'>
  <div :class='rootCssClass'>
    <svg :id='graphElementId'></svg>
  </div>
</template>

<script>
import Moment from 'moment';
import drawGraph from '../presenters/data-graph';
import bus from '../lib/event-bus';

export default {
  data: () => ({
    redrawScheduled: false,
  }),

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
    zoom: {
      required: false,
      type: Boolean,
      default: false,
    },
  },

  computed: {
    graphElementId() {
      return `${this.elementId}-graph`;
    },

    rootCssClass() {
      return `o-data-view__graph${this.zoom ? ' u-graph-zoomed' : ''}`;
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
      return Moment(this.$store.state.fromDate);
    },

    toMoment() {
      return Moment(this.$store.state.toDate);
    },

    /** @return The duration of the selected dates, in months */
    period() {
      return Math.ceil(this.toMoment.diff(this.fromMoment, 'months', true));
    },

    /** @return The date range for the selected dates */
    dateRange() {
      return [
        this.fromMoment.startOf('month').toDate(),
        this.toMoment.startOf('month').toDate(),
      ];
    },
  },

  mounted() {
    this.$watch('$store.state.selectedStatistics', this.updateGraph, { deep: true });
    this.$watch('$store.state.queryResults', this.updateGraph, { deep: true });

    bus.$on('open-close-data-view', this.onOpenCloseDataView);

    if (this.zoom) {
      this.updateGraph();
    }
  },

  watch: {
    indicator() {
      this.redrawGraphNextTick();
    },
  },

  methods: {
    updateGraph() {
      if (this.dataProjection && this.isVisible(this.graphElementId)) {
        this.redrawGraphNextTick();
      }
    },

    /** Ensures that only one redrawing of the graph is scheduled at once, even if
     * called multiple times */
    redrawGraphNextTick() {
      if (!this.redrawScheduled) {
        this.redrawScheduled = true;
        this.$nextTick(this.redrawGraph);
      }
    },

    redrawGraph() {
      this.redrawScheduled = false;

      drawGraph(
        this.dataProjection,
        {
          dateRange: this.dateRange,
          elementId: this.graphElementId,
          indicatorId: this.indicator ? this.indicator.rootName : 'salesVolume',
          indicator: this.indicator,
          period: this.period,
          selectedStatistics: this.selectedStatistics,
          theme: this.theme,
          location: this.$store.state.location,
          zoom: this.zoom,
        },
      );
    },

    isVisible(id) {
      const elem = document.getElementById(id);
      return elem && !!(elem.offsetWidth || elem.offsetHeight || elem.getClientRects().length);
    },

    onOpenCloseDataView({ id, closing }) {
      if (this.elementId === id && !closing) {
        this.redrawGraphNextTick();
      }
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
