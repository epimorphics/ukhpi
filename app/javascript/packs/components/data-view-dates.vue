<template lang='html'>
  <span class='o-data-view__dates' v-if='fromDate'>
    {{ fromDateFormatted }} to {{ toDateFormatted }}
    <el-button size='small'>
      <i class='fa fa-edit'></i>
    </el-button>
  </span>
</template>

<script>
import Moment from 'moment';

export default {
  data: () => ({
    fromDate: null,
    toDate: null,
  }),

  props: [
    'initialFromDate',
    'initialToDate',
  ],

  computed: {
    fromDateFormatted() {
      return this.fromDate.format('MMM YYYY');
    },

    toDateFormatted() {
      return this.toDate.format('MMM YYYY');
    },
  },

  mounted() {
    this.fromDate = Moment(this.initialFromDate.date);
    this.toDate = Moment(this.initialToDate.date);
  },
};
</script>

<style lang="scss">
.o-data-view__dates {
  float: right;
}
</style>
