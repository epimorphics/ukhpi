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
  </div>
</template>

<script>
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
  },

  computed: {
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
      return `ukhpi:${this.indicator ? this.indicator.root_name : ''}${stat.root_name}`;
    },
  },
};
</script>

<style lang='scss'>
</style>
