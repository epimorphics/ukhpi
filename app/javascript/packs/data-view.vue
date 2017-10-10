<template lang="html">
  <div class='o-data-view__vue-root u-js-only'>
    <div class='o-data-view__js-options'>
      <data-view-location :element-id='elementId'></data-view-location>
      <data-view-dates></data-view-dates>

      <data-view-statistics :initial-statistics='theme.statistics'></data-view-statistics>
    </div>
    <div class='o-data-view__data-display'>
      <el-tabs
        v-model='activeTab'
        @tab-click='onChangeTab'
      >
        <el-tab-pane label='View as graphs' name='graphs-tab'>
          <data-view-graph
            :theme='theme'
            :indicator='indicator'
            :elementId='elementId'
          >
          </data-view-graph>
        </el-tab-pane>
        <el-tab-pane label='View as data' name='data-tab'>
          <data-view-table
            :statistics='theme.statistics'
            :indicator='indicator'
          >
          </data-view-table>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>

</template>

<script>
import kebabCase from 'kebab-case';
import DataViewLocation from './components/data-view-location.vue';
import DataViewDates from './components/data-view-dates.vue';
import DataViewStatistics from './components/data-view-statistics.vue';
import DataViewTable from './components/data-view-table.vue';
import DataViewGraph from './components/data-view-graph.vue';
import store from './store/index';
import { INITIALISE } from './store/mutation-types';
import bus from './lib/event-bus';

export default {
  data: () => ({
    activeTab: 'graphs-tab',
    theme: null,
    indicator: null,
    location: null,
    fromDate: null,
    toDate: null,
    first: false,
  }),

  components: {
    DataViewLocation,
    DataViewDates,
    DataViewStatistics,
    DataViewTable,
    DataViewGraph,
  },

  beforeMount() {
    const attrs = this.$el.attributes;

    for (let i = 0; i < attrs.length; i += 1) {
      const attr = attrs.item(i);

      if (attr.name.match(/^data-/)) {
        const name = kebabCase.reverse(attr.name.replace(/^data-/, ''));
        const value = JSON.parse(attr.value);
        this.$set(this, name, value);
      }
    }
  },

  mounted() {
    this.checkStoreInitialised();
    bus.$on('open-close-data-view', this.onOpenCloseDataView);
  },

  computed: {
    /** @return The node ID that would have been assigned to this data view, given
     * the indicator and theme */
    elementId() {
      const indicatorSlug = this.indicator ? `${this.indicator.slug}-` : '';
      return `${indicatorSlug}${this.theme.slug}`.replace(/_/g, '-');
    },
  },

  methods: {
    checkStoreInitialised() {
      // we only need this to happen once, so the page renderer sets a flag on
      // the first data-view component on the page
      if (this.first) {
        this.initialiseStore();
      }
    },

    initialiseStore() {
      this.$store.commit(INITIALISE, {
        location: this.location,
        fromDate: this.fromDate.date,
        toDate: this.toDate.date,
      });
    },

    onChangeTab() {
    },

    onOpenCloseDataView({ id, closing }) {
      if (this.elementId === id) {
        const node = document.getElementById(id);
        const cls = node.className.replace(
          /o-data-view--(open|closed)/,
          `o-data-view--${closing ? 'closed' : 'open'}`,
        );
        node.className = cls;
      }
    },
  },

  store,
};
</script>

<style lang="scss">
</style>
