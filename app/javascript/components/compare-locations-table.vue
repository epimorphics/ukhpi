<template lang='html'>
  <div class='o-compare__table'>
    <h2 class='o-heading--3'>
      {{ tableCaption }}
    </h2>
    <el-table
      :data='tableData'
    >
      <el-table-column
        prop='date'
        label='Date'
        align='left'
        :formatter='dateFormatter'
      >
      </el-table-column>
      <el-table-column
        v-for='location in locations'
        :key='location.gss'
        :prop='location.gss'
        :label='location.labels.en'
        align='right'
        :formatter='valueFormatter'
      >
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import _ from 'lodash';
import Moment from 'moment';
import Numeral from 'numeral';

export default {
  data: () => ({
    tableData: [],
  }),

  props: {
    statistic: {
      type: Object,
      required: true,
    },

    indicator: {
      type: Object,
      required: true,
    },

    locations: {
      type: Array,
      required: true,
    },
  },

  computed: {
    pred() {
      return `ukhpi:${this.indicator.rootName}${this.statistic.rootName}`;
    },

    compareResults() {
      return this.$store.state.compareResults;
    },

    tableCaption() {
      const indLabel = this.indicator.label.toLocaleLowerCase();
      const statLabel = this.statistic.label.toLocaleLowerCase();
      let locLabel = '';

      switch (this.locations.length) {
        case 0:
          locLabel = 'zero locations';
          break;
        case 1:
          locLabel = 'one location';
          break;
        case 2:
          locLabel = 'two locations';
          break;
        default:
          locLabel = `${this.locations.length} locations`;
      }

      return `Comparison of ${indLabel} of ${statLabel} for ${locLabel}`;
    },
  },

  watch: {
    /**
     * When the compareResults change, because we have new data in the Vuex store,
     * calculate the table data. The table data consists of the values from the data
     * series for the selected predicate (formed from selected statistic and indicator),
     * plus the series dates. To accurately calculate the series dates, we need to ensure
     * that we're taking dates from the longest available series, because some statistics
     * lag in some locations so we can have partial series in some cases.
     */
    compareResults() {
      const tSeries = _.mapValues(this.compareResults, qResults => qResults.series(this.pred));
      const longestSeries = _.last(_.sortBy(_.values(tSeries), series => series.length));

      const dates = _.map(longestSeries, datum => ({ date: new Date(datum.x) }));
      const tData = _.map(tSeries, (series, gss) => _.map(series, datum => ({ [gss]: datum.y })));

      this.tableData = _.map(_.zip(dates, ...tData), row => _.assign({}, ...row));
    },
  },

  methods: {
    dateFormatter: (row, column, date) => Moment(date).format('MMM YYYY'),

    valueFormatter(row, col, value) {
      const ind = this.indicator.slug;
      let format = '0,0';
      let scale = 1;

      if (ind === 'avg') {
        format = '$0,0.';
      } else if (ind === 'pac' || ind === 'pmc') {
        format = '0.0%';
        scale = 100;
      } else if (ind === 'hpi') {
        format = '0,0.0';
      }

      return Numeral(value / scale).format(format);
    },
  },
};
</script>

<style lang='scss'>
</style>
