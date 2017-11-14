<template lang='html'>
  <div class='o-compare__table'>
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
  },

  watch: {
    compareResults() {
      const tSeries = _.mapValues(this.compareResults, qResults => qResults.series(this.pred));
      const dates = _.map(_.first(_.values(tSeries)), datum => ({ date: new Date(datum.x) }));
      const tData = _.map(tSeries, (series, gss) => _.map(series, datum => ({ [gss]: datum.y })));
      this.tableData = _.map(_.zip(dates, ...tData), row => _.assign({}, ...row));
    },
  },

  methods: {
    dateFormatter: (row, column, date) => Moment(date).format('MMM YYYY'),

    valueFormatter(row, col, value) {
      const ind = this.indicator.slug;
      let format = '0,0';

      if (ind === 'avg') {
        format = '$0,0.';
      } else if (ind === 'pac' || ind === 'pmc') {
        format = '0.0%';
      }

      return Numeral(value).format(format);
    },
  },
};
</script>

<style lang='scss'>
</style>
