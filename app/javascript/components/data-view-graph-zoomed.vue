<template lang='html'>
  <div class='c-data-view-graph-zoomed'>
    <el-dialog
      :visible.sync='showZoomedGraph'
      :title='dialogTitle'
      :show-close='true'
      width='80%'
      top='10vh'
      @close='onCloseDialog'
    >
    <div class='o-data-view__js-options'>
      <data-view-statistics :initial-statistics='availableStatistics'></data-view-statistics>
    </div>

    <data-view-graph
      :elementId='elementId'
      :theme='theme'
      :indicator='indicator'
      :zoom='true'
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
  }),

  computed: {
    dialogTitle() {
      const root = this.graphConfig.elementId && this.graphConfig.elementId.replace(/-graph/, '');
      if (root) {
        const node = document.querySelector(`#${root} h2`);
        return node && node.innerText.replace(/ hide *$/, '');
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
    },
  },

  mounted() {
    bus.$on('zoomGraph', this.onZoomGraph);
  },
};
</script>

<style lang='css'>
</style>
