<template lang='html'>
  <div class='o-data-view__table'>
    <el-table
      :data='tableData'
    >
      <el-table-column
        prop='ukhpi:refMonth'
        label='Date'
      >
      </el-table-column>
      <el-table-column
        v-for='column in columns'
        :key='column.slug'
        :prop='columnProp(column)'
        :label='column.label'
      >
      </el-table-column>
    </el-table>
    <div class='o-data-view__table-print u-text-right'>
      <a :href='printUrl' target='_' class='el-button el-button--primary'
      >
        Print this data
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
      const location = this.$store.state.location || {};
      const params = {
        in: [this.indicator.slug],
        st: this.statistics
          .filter(stat => stat.isSelected)
          .map(stat => stat.slug),
        thm: [this.theme.slug],
        from: this.$store.state.fromDate,
        to: this.$store.state.toDate,
        location: location.uri,
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
  },
};
</script>

<style lang='scss'>
</style>
