<template lang='html'>
  <div class='o-data-view__js-options-statistics'>
    <span v-for='statistic in statistics' class='o-data-view__js-options-statistics'>
      {{ statistic.label}}
    </span>
  </div>
</template>

<script>
export default {
  data: () => ({
    statistics: {},
  }),

  props: [
    'initialStatistics',
  ],

  mounted() {
    this.statistics = this.initialStatistics;
  },
};
</script>

<style lang='scss'>
</style>
