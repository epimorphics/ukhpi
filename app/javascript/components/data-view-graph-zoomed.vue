<template lang='html'>
  <div class='c-data-view-graph-zoomed'>
    <el-dialog
      :visible.sync='showZoomedGraph'
      :title='dialogTitle'
      :show-close='true'
      width='80%'
      top='10vh'
      @close='onCloseDialog'
      @open='onOpenDialog'
    >
    <div class='o-data-view__js-options'>
      <data-view-statistics :initial-statistics='availableStatistics' :zoom='true'></data-view-statistics>
    </div>

    <data-view-graph
      :elementId='elementId'
      :theme='theme'
      :indicator='indicator'
      :zoom='true'
      :timestamp='timestamp'
    ></data-view-graph>
  </el-dialog>
  </div>
</template>

<script>
import bus from '../lib/event-bus';
import DataViewGraph from './data-view-graph.vue';
import DataViewStatistics from './data-view-statistics.vue';
import AvailableStatistics from '../mixins/available-statistics';

export default {
  mixins: [AvailableStatistics],

  data: () => ({
    graphConfig: {},
    showZoomedGraph: false,
    timestamp: 0, // keeps track of dialog opens and closes
  }),

  computed: {
    dialogTitle() {
      const root = this.graphConfig.elementId && this.graphConfig.elementId.replace(/-graph/, '');
      if (root) {
        const node = document.querySelector(`#${root} h2`);
        return node && node.innerText.replace(/(hide|reveal) *$/, '');
      }

      return '';
    },

    elementId() {
      return `${this.graphConfig.elementId}-zoomed`;
    },

    theme() {
      return this.graphConfig.theme || {};
    },

    indicator() {
      return this.graphConfig.indicator || {};
    },
  },

  components: {
    DataViewGraph,
    DataViewStatistics,
  },

  methods: {
    onZoomGraph(config) {
      this.graphConfig = config.graphConfig;
      this.showZoomedGraph = true;
    },

    onCloseDialog() {
      this.timestamp += 1;
    },

    /** When we open the dialog, if this is not the first time then wait one update
     * cycle then update the timestamp. This way, the change of timestamp will be
     * noticed by the graph component, which will know to update the graph in case
     * the selected statistics have changed since first draw. */
    onOpenDialog() {
      if (this.timestamp > 0) {
        this.$nextTick(function deferredUpdate() { this.timestamp += 1; });
      }
    },
  },

  mounted() {
    bus.$on('zoomGraph', this.onZoomGraph);
  },
};
</script>

<style lang='css'>
</style>
