<template lang='html'>
  <div class='c-options-selection__dates'>
    <span class='' v-if='fromDate'>
      <el-button
        @click='onChangeDates'
        class='c-options-selection__button'
        title='change start or end date'
      >
        {{ fromDateFormatted }} to {{ toDateFormatted }}
        <i class='fa fa-edit'></i>
      </el-button>
    </span>

    <el-dialog
      title='Change the date range'
      :visible.sync='dialogVisible'
      :show-close='true'
    >
      <el-row>
        <el-col :span='12'>
          <label>
            Start<span class='u-sr-only'>dd/mm/yyyy day two digits, month two digits, year four digits</span>:
            <el-date-picker
              v-model='newFromDate'
              type='month'
              placeholder='Starting from'>
            </el-date-picker>
          </label>
        </el-col>
        <el-col :span='12'>
          <label>
            End<span class='u-sr-only'>dd/mm/yyyy day two digits, month two digits, year four digits</span>:
            <el-date-picker
              v-model='newToDate'
              type='month'
              placeholder='Starting from'>
            </el-date-picker>
          </label>
        </el-col>
      </el-row>
      <el-row>
        <p v-if='validationMessage'>
          <el-alert
            :title='validationMessage'
            type='warning'>
          </el-alert>
        </p>
      </el-row>
      <span slot='footer' class='dialog-footer'>
        <el-button @click='dialogVisible = false'>Cancel</el-button>
        <el-button type='primary' @click='onSaveChanges'>Confirm</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import Moment from 'moment';
import { SET_DATES } from '../store/mutation-types';
import bus from '../lib/event-bus';

export default {
  data: () => ({
    newFromDate: null,
    newToDate: null,
    dialogVisible: false,
    validationMessage: null,
  }),

  computed: {
    fromDate() {
      return Moment(this.$store.state.fromDate).toDate();
    },

    toDate() {
      return Moment(this.$store.state.toDate).toDate();
    },

    fromDateFormatted() {
      return Moment(this.fromDate).format('MMM YYYY');
    },

    toDateFormatted() {
      return Moment(this.toDate).format('MMM YYYY');
    },
  },

  methods: {
    onChangeDates() {
      this.newFromDate = this.fromDate;
      this.newToDate = this.toDate;
      this.dialogVisible = true;
    },

    onSaveChanges() {
      if (Moment(this.newToDate).isBefore(Moment(this.newFromDate))) {
        this.validationMessage = 'The start date must be earlier than the end date';
      } else {
        const from = Moment(this.newFromDate).format('YYYY-MM-DD');
        const to = Moment(this.newToDate).format('YYYY-MM-DD');
        this.$store.commit(SET_DATES, { from, to });
        this.dialogVisible = false;
      }
    },

    updateFromDate(dateStr) {
      this.fromDate = Moment(dateStr).date();
    },

    updateToDate(dateStr) {
      this.toDate = Moment(dateStr).date();
    },
  },

  mounted() {
    bus.$on('change-dates', this.onChangeDates);
  },
};
</script>

<style lang='scss'>
</style>
