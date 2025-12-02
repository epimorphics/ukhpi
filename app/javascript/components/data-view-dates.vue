<template>
  <FocusTrap
    v-model="dialogVisible"
    :initial-focus="initialFocusElement"
  >
    <div class="c-options-selection__dates">
      <span
        v-if="fromDate"
        class=""
      >
        <ElButton
          class="c-options-selection__button"
          :title="$t('js.dates_picker.select_dates')"
          @click="onChangeDates"
        >
          {{ fromDateFormatted }}
          {{ $t('preposition.to') }}
          {{ toDateFormatted }}
          <i class="fa fa-edit" />
        </ElButton>
      </span>

      <ElDialog
        :title="$t('js.dates_picker.date_range_prompt')"
        :visible.sync="dialogVisible"
        :show-close="true"
      >
        <ElRow>
          <ElCol :span="12">
            <label>
              {{ $t("js.dates_picker.start") }}<span class="u-sr-only">{{ $t('browse.edit.form.dates_format_sr') }}</span>:
              <ElDatePicker
                ref="fromDatePicker"
                v-model="newFromDate"
                type="month"
                :placeholder="$t('js.compare.dates_from')"
              />
            </label>
          </ElCol>
          <ElCol :span="12">
            <label>
              {{ $t("js.dates_picker.end") }}<span class="u-sr-only">{{ $t('browse.edit.form.dates_format_sr') }}</span>:
              <ElDatePicker
                v-model="newToDate"
                type="month"
                :placeholder="$t('js.compare.dates_to')"
              />
            </label>
          </ElCol>
        </ElRow>
        <ElRow>
          <p v-if="validationMessage">
            <ElAlert
              :title="validationMessage"
              type="warning"
            />
          </p>
        </ElRow>
        <span
          slot="footer"
          class="dialog-footer"
        >
          <ElButton @click="dialogVisible = false">{{ $t("js.action.cancel") }}</ElButton>
          <ElButton
            type="primary"
            @click="onSaveChanges"
          >{{ $t("js.action.confirm") }}</ElButton>
        </span>
      </ElDialog>
    </div>
  </FocusTrap>
</template>

<script>
import Moment from 'moment'
import { FocusTrap } from 'focus-trap-vue'
import { SET_DATES } from '../store/mutation-types'
import bus from '../lib/event-bus'
import { mutateName } from '../lang/welsh-name-mutations'

export default {
  name: 'DataViewDates',

  components: {
    FocusTrap,
  },

  props: {
    prefix: {
      required: false,
      type: String,
      default: () => '',
    },
  },

  data: () => ({
    newFromDate: null,
    newToDate: null,
    dialogVisible: false,
    validationMessage: null,
  }),

  computed: {
    fromDate () {
      return Moment(this.$store.state.fromDate).toDate()
    },

    toDate () {
      return Moment(this.$store.state.toDate).toDate()
    },

    fromDateFormatted () {
      if (this.prefix) {
        return mutateName(
          Moment(this.fromDate).format('MMMM YYYY'),
          this.$t(this.prefix),
          window.ukhpi.locale,
        ).name
      }

      return Moment(this.fromDate).format('MMMM YYYY')
    },

    toDateFormatted () {
      return mutateName(
        Moment(this.toDate).format('MMMM YYYY'),
        this.$t('preposition.to'),
        window.ukhpi.locale,
      ).name
    },
  },

  mounted () {
    bus.$on('change-dates', this.onChangeDates)
  },

  methods: {
    initialFocusElement () {
      return this.$refs.fromDatePicker
    },

    onChangeDates () {
      this.newFromDate = this.fromDate
      this.newToDate = this.toDate
      this.dialogVisible = true
    },

    onSaveChanges () {
      if (Moment(this.newToDate).isBefore(Moment(this.newFromDate))) {
        this.validationMessage = this.$t('js.compare.validation_dates')
      } else {
        const from = Moment(this.newFromDate).format('YYYY-MM-DD')
        const to = Moment(this.newToDate).format('YYYY-MM-DD')
        this.$store.commit(SET_DATES, { from, to })
        this.dialogVisible = false
      }
    },

    updateFromDate (dateStr) {
      this.fromDate = Moment(dateStr).date()
    },

    updateToDate (dateStr) {
      this.toDate = Moment(dateStr).date()
    },
  },
}
</script>
