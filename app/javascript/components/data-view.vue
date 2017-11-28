<template lang="html">
  <div class='o-data-view__vue-root u-js-only'>
    <div class='o-data-view__js-options'>
      <data-view-statistics :initial-statistics='availableStatistics'></data-view-statistics>
    </div>
    <div class='o-data-view__data-display'>
      <el-tabs
        v-model='activeTab'
        @tab-click='onChangeTab'
      >
        <el-tab-pane label='See data graph' name='graphs-tab'>
          <data-view-graph
            :theme='theme'
            :indicator='indicator'
            :elementId='elementId'
          >
          </data-view-graph>
        </el-tab-pane>
        <el-tab-pane label='See data table' name='data-tab'>
          <data-view-table
            :statistics='availableStatistics'
            :indicator='indicator'
          >
          </data-view-table>
        </el-tab-pane>
        <el-tab-pane label='Download this data' name='download-tab'>
          <data-view-download
            :theme='theme'
            :indicator='indicator'
          >
          </data-view-download>
        </el-tab-pane>
        <el-tab-pane label='Compare with location ...' name='compare-tab'>
          <p v-if='selectedLocation'>
            You can see how {{ selectedLocation.labels.en }} compares to
            other places:
            <el-button @click='onCompareSelect'>
              select another location
            </el-button>
          </p>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>

</template>

<script>
import kebabCase from 'kebab-case';
import _ from 'lodash';
import DataViewLocation from './data-view-location.vue';
import DataViewDates from './data-view-dates.vue';
import DataViewStatistics from './data-view-statistics.vue';
import DataViewTable from './data-view-table.vue';
import DataViewGraph from './data-view-graph.vue';
import DataViewDownload from './data-view-download.vue';
import store from '../store/index';
import { INITIALISE, SELECT_STATISTIC } from '../store/mutation-types';
import bus from '../lib/event-bus';

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
    DataViewDownload,
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

    selectedLocation() {
      return this.$store.state.location;
    },

    isVolumeIndicator() {
      return this.indicator.isVolume;
    },

    availableStatistics() {
      return this.theme.statistics.filter(this.statisticIsAvailable);
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
      if (this.elementId !== id) {
        return;
      }

      if (!closing) {
        this.ensureSomeSelectedStatisitics();
      }
      this.updateOpenCloseState(id, closing);
    },

    /** Set the CSS class of the section element according to whether we are opening or closing */
    updateOpenCloseState(id, closing) {
      const node = document.getElementById(id);
      const cls = node.className.replace(
        /o-data-view--(open|closed)/,
        `o-data-view--${closing ? 'closed' : 'open'}`,
      );
      node.className = cls;
    },

    /** Ensure that at least one statistic is selected, or we will have an empty graph */
    ensureSomeSelectedStatisitics() {
      const stor = this.$store;
      const selectedStats = stor.state.selectedStatistics;

      const atLeastOneSelected =
        this.theme
          .statistics
          .map(stat => selectedStats[stat.slug])
          .includes(true);

      if (!atLeastOneSelected) {
        // if none are currently selected, select them all
        this.availableStatistics.forEach(stat => stor.commit(
          SELECT_STATISTIC,
          { slug: stat.slug, isSelected: true },
        ));
      }
    },

    onCompareSelect() {
      const vm = this;
      const statistic =
        _.find(this.availableStatistics, stat => vm.$store.state.selectedStatistics[stat.slug]);

      if (statistic) {
        bus.$emit('select-comparison', {
          indicator: this.indicator,
          statistic,
        });
      }
    },

    /** A statistic is available if it's not the volume indicator, or it is and a given
     * statistic does have a sales volume (which not all do).
     * @return True if the statistic should be available for this indicator
     */
    statisticIsAvailable(stat) {
      return !this.isVolumeIndicator || stat.hasVolume;
    },
  },

  watch: {
    selectedLocation() {
      document
        .querySelector(`#${this.elementId} .o-data-view__location-name`)
        .innerHTML = this.selectedLocation.labels.en;
    },
  },

  store,
};
</script>

<style lang="scss">
</style>