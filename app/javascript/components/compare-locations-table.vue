<template lang='html'>
  <div class='o-compare__table'>
    <h2 class='o-heading--3'>
      {{ tableCaption }}
    </h2>
    <table class='o-data-table'>
      <thead>
        <tr>
          <th class='u-left' scope='col'>{{ $t('js.data_table.date') }}</th>
          <th v-for='location in locations'
              :key='`th-${location.gss}`'
              class='u-right'
              scope='col'
          >
            {{ location.labels[currentLocale] }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for='(row, rowIndex) in tableData' :key='`row-${rowIndex}`'>
          <td class='u-left'>{{ dateFormatter(row['date']) }}</td>
          <td v-for='(location, colIndex) in locations' :key='`td-${colIndex}-${rowIndex}`' class='u-right'>
            {{ valueFormatter(row[location.gss]) }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import _ from 'lodash';
import Moment from 'moment';
import Numeral from 'numeral';

/**
 * Helper to normalise data series to a given reference set of dates. If a series
 * does not have entries for all of the given dates, add blank entries.
 *
 * Post-condition: each series in tSeries will have a dated entry for every
 * date in dates, and each series in tSeries will be sorted in ascending order
 * of date.
 */
function ensureSeriesDates(dates, tSeries) {
  _.each(tSeries, (series) => {
    _.each(dates, (date) => {
      const dateValue = date.date.valueOf();
      if (!_.find(series, datum => datum.x.valueOf() === dateValue)) {
        series.push({ x: date.date });
      }
    });

    series.sort((datum0, datum1) => datum0.x.valueOf() - datum1.x.valueOf());
  });
}

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
    currentLocale () {
      return window.ukhpi.locale
    },

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
          locLabel = this.$t('js.compare.zero_locations')
          break;
        case 1:
          locLabel = this.$t('js.compare.one_locations')
          break;
        case 2:
          locLabel = this.$t('js.compare.two_locations')
          break;
        default:
          locLabel = this.$t('js.compare.n_locations', { num: this.locations.length })
      }

      return this.$t('js.compare.title', { indLabel, statLabel, locLabel });
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
      ensureSeriesDates(dates, tSeries);
      const tData = _.map(tSeries, (series, gss) => _.map(series, datum => ({ [gss]: datum.y })));

      this.tableData = _.map(_.zip(dates, ...tData), row => _.assign({}, ...row));
    },
  },

  methods: {
    dateFormatter: (date) => Moment(date).format('MMM YYYY'),

    valueFormatter(value) {
      const ind = this.indicator.slug;
      let format = '0,0';
      let scale = 1;

      if (_.isUndefined(value)) {
        return 'no data';
      }

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
  }
};
</script>

<style lang='scss'>
</style>
