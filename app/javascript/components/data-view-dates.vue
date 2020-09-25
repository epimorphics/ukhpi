<template lang='html'>
  <focus-trap v-model='dialogVisible' :initial-focus='initialFocusElement'>
    <div class='c-options-selection__dates'>
      <span class='' v-if='fromDate'>
        <el-button
          @click='onChangeDates'
          class='c-options-selection__button'
          :title='$t("js.dates_picker.select_dates")'
        >
          {{ fromDateFormatted }}
          {{ $t('preposition.to') }}
          {{ toDateFormatted }}
          <i class='fa fa-edit'></i>
        </el-button>
      </span>

      <el-dialog
        :title='$t("js.dates_picker.date_range_prompt")'
        :visible.sync='dialogVisible'
        :show-close='true'
      >
        <el-row>
          <el-col :span='12'>
            <label>
              {{ $t("js.dates_picker.start") }}<span class='u-sr-only'>{{ $t('browse.edit.form.dates_format_sr') }}</span>:
              <el-date-picker
                v-model='newFromDate'
                type='month'
                :placeholder='$t("js.compare.dates_from")'
                ref='fromDatePicker'
              ></el-date-picker>
            </label>
          </el-col>
          <el-col :span='12'>
            <label>
              {{ $t("js.dates_picker.end") }}<span class='u-sr-only'>{{ $t('browse.edit.form.dates_format_sr') }}</span>:
              <el-date-picker
                v-model='newToDate'
                type='month'
                :placeholder='$t("js.compare.dates_to")'>
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
          <el-button @click='dialogVisible = false'>{{ $t("js.action.cancel") }}</el-button>
          <el-button type='primary' @click='onSaveChanges'>{{ $t("js.action.confirm") }}</el-button>
        </span>
      </el-dialog>
    </div>
  </focus-trap>
</template>

<script>
import Moment from 'moment';
import { FocusTrap } from 'focus-trap-vue'
import { SET_DATES } from '../store/mutation-types';
import bus from '../lib/event-bus';
import { mutateName } from 'lang/welsh-name-mutations'

export default {
  components: {
    FocusTrap
  },

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
      return mutateName(
        Moment(this.toDate).format('MMM YYYY'),
        this.$t('preposition.to'),
        window.ukhpi.locale
      ).name
    },
  },

  methods: {
    initialFocusElement () {
      return this.$refs.fromDatePicker
    },

    onChangeDates() {
      this.newFromDate = this.fromDate;
      this.newToDate = this.toDate;
      this.dialogVisible = true;
    },

    onSaveChanges() {
      if (Moment(this.newToDate).isBefore(Moment(this.newFromDate))) {
        this.validationMessage = this.$t('js.compare.validation_dates');
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
