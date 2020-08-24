<template lang='html'>
  <div class='o-data-view__table'>
    <table class='o-data-table'>
      <thead>
        <tr>
          <th class='u-left' scope='col'>{{ $t('js.data_table.date') }}</th>
          <th v-for='column in columns'
              :key='`th-${column.slug}`'
              class='u-right'
              scope='col'
          >
            {{ column.label }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for='(row, rowIndex) in tableData' :key='`row-${rowIndex}`'>
          <td class='u-left'>{{ row['ukhpi:refMonth'] }}</td>
          <td v-for='(column, colIndex) in columns' :key='`td-${colIndex}-${rowIndex}`' class='u-right'>
            {{ row[columnProp(column)] }}
          </td>
        </tr>
      </tbody>
    </table>
    <div class='o-data-view__table-print'>
      <a :href='printUrl' target='_' class='o-print-action'
      >
        <i class='fa fa-print'></i> {{ $t('js.action.print_table') }}
      </a>
    </div>
  </div>
</template>

<script>
import Routes from '../lib/routes.js.erb';

export default {
  data: () => ({
    tableData: [],
  }),

  props: {
    statistics: {
      type: Array,
      required: true,
    },

    indicator: {
      type: Object,
      required: false,
    },

    theme: {
      type: Object,
      required: false,
    },
  },

  computed: {
    printUrl() {
      const vm = this;
      const location = this.$store.state.location || {};
      const params = {
        in: [this.indicator.slug],
        st: this.statistics
          .filter(stat => vm.isSelectedStatistic(stat.slug))
          .map(stat => stat.slug),
        thm: [this.theme.slug],
        from: this.$store.state.fromDate,
        to: this.$store.state.toDate,
        location: location.uri,
        lang: this.$locale
      };

      return `${Routes.printPath(params)}`;
    },

    columns() {
      return this.statistics.filter(stat => this.isSelectedStatistic(stat.slug));
    },

    queryResults() {
      return this.$store.state.queryResults;
    },
  },

  watch: {
    queryResults() {
      const results = this.queryResults && this.queryResults.results();
      if (results) {
        this.tableData = results.map(result => result.asTableData());
      }
    },
  },

  methods: {
    isSelectedStatistic(slug) {
      return this.$store.state.selectedStatistics[slug];
    },

    columnProp(stat) {
      return `ukhpi:${this.indicator ? this.indicator.rootName : ''}${stat.rootName}`;
    },
  }
};
</script>

<style lang='scss'>
</style>
