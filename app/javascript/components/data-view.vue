<template>
  <div class="o-data-view__vue-root u-js-only">
    <div class="o-data-view__js-options">
      <DataViewStatistics
        :initial-statistics="availableStatistics"
        :zoom="false"
      />
    </div>
    <div
      role="tabpanel"
      aria-describedby="tabpanel-accessibility-message"
      class="o-data-view__data-display"
    >
      <ElTabs
        v-model="activeTab"
      >
        <ElTabPane
          :label="$t('js.action.data_graph')"
          :name="`graphs-tab-${indicator.slug}-${theme.slug}`"
        >
          <DataViewGraph
            :key="`data-view-graph-${theme}-${indicator}-${elementId}`"
            :theme="theme"
            :indicator="indicator"
            :element-id="elementId"
          />
        </ElTabPane>
        <ElTabPane
          :label="$t('js.action.data_table')"
          :name="`data-tab-${indicator.slug}-${theme.slug}`"
        >
          <DataViewTable
            :key="`data-view-table-${theme}-${indicator}-${elementId}`"
            :statistics="availableStatistics"
            :indicator="indicator"
            :theme="theme"
          />
        </ElTabPane>
        <ElTabPane
          :label="$t('js.action.download')"
          :name="`download-tab${indicator.slug}-${theme.slug}`"
        >
          <DataViewDownload
            :theme="theme"
            :indicator="indicator"
          />
        </ElTabPane>
        <ElTabPane
          :label="$t('js.action.compare')"
          :name="`compare-tab-${indicator.slug}-${theme.slug}`"
        >
          <p v-if="selectedLocation">
            {{ $t('js.compare.prompt', { selectedLocationLabel: selectedLocationLabel }) }}
            <ElButton @click="onCompareSelect">
              {{ $t('js.compare.select_action') }}
            </ElButton>
          </p>
        </ElTabPane>
      </ElTabs>
    </div>
    <p
      id="tabpanel-accessibility-message"
      class="u-sr-only"
      aria-hidden="true"
    >
      {{ $t('js.action.accessibility_tabpanel') }}
    </p>
  </div>
</template>

<script>
import kebabCase from 'kebab-case'
import _ from 'lodash'
// import DataViewLocation from './data-view-location.vue';
// import DataViewDates from './data-view-dates.vue';
import DataViewStatistics from './data-view-statistics.vue'
import DataViewTable from './data-view-table.vue'
import DataViewGraph from './data-view-graph.vue'
import DataViewDownload from './data-view-download.vue'
import store from '@/store/index'
import { INITIALISE, SELECT_STATISTIC } from '@/store/mutation-types'
import bus from '@/lib/event-bus'
import safeForEach from '@/lib/safe-foreach'
import AvailableStatistics from '@/mixins/available-statistics'
import i18n from '@/lang'
import { mutateName } from '@/lang/welsh-name-mutations'

/**
 * @typedef {object} DataViewData
 * @property {string} activeTab
 * @property {null} theme
 * @property {null} indicator
 * @property {null} location
 * @property {null} fromDate
 * @property {null} toDate
 * @property { boolean } first
 */

export default {

  components: {
    // Registered but not used directly:
    // DataViewLocation,
    // DataViewDates,
    DataViewStatistics,
    DataViewTable,
    DataViewGraph,
    DataViewDownload,
  },
  mixins: [AvailableStatistics],

  i18n,

  /**
   * @returns {DataViewData}
   */
  data () {
    return {
      activeTab: '',
      theme: null,
      indicator: null,
      location: null,
      fromDate: null,
      toDate: null,
      first: false,
    }
  },

  computed: {
    /** @return The node ID that would have been assigned to this data view, given
     * the indicator and theme */
    elementId () {
      const indicatorSlug = this.indicator ? `${this.indicator.slug}-` : ''
      return `${indicatorSlug}${this.theme.slug}`.replace(/_/g, '-')
    },

    selectedLocation () {
      return this.$store.state.location
    },

    selectedLocationLabel () {
      return this.selectedLocation.labels[this.$locale] || this.selectedLocation.labels.en
    },

    selectedLocationLabelWelsh () {
      return this.selectedLocation.labels.cy
    },
  },

  watch: {
    selectedLocation () {
      let name = this.selectedLocationLabel
      let preposition = this.$t('preposition.in')

      // we only want to perform Welsh consonant mutation IF the location has a given
      // Welsh name. If we're in Welsh language mode, but showing a location with no
      // given Welsh name, we use the English name instead but we *don't* do mutation.
      if (window.ukhpi.locale === 'cy' && this.selectedLocationLabelWelsh) {
        const mutated = mutateName(this.selectedLocationLabelWelsh, preposition, 'cy')
        name = mutated.name
        preposition = mutated.preposition
      }

      let nodes = document.querySelectorAll('.o-data-view__location-name')
      safeForEach(nodes, (node) => { node.innerHTML = name })

      nodes = document.querySelectorAll('.o-data-view__location-preposition')
      safeForEach(nodes, (node) => { node.innerHTML = preposition })
    },
  },

  beforeMount () {
    const attrs = this.$el.attributes

    for (let i = 0; i < attrs.length; i += 1) {
      const attr = attrs.item(i)

      if (attr.name.match(/^data-/)) {
        const name = kebabCase.reverse(attr.name.replace(/^data-/, ''))
        const value = JSON.parse(attr.value)
        this.$set(this, name, value)
      }
    }
  },

  mounted () {
    this.checkStoreInitialised()
    bus.$on('open-close-data-view', this.onOpenCloseDataView)

    this.activeTab = `graphs-tab-${this.indicator.slug}-${this.theme.slug}`
  },

  methods: {
    checkStoreInitialised () {
      // we only need this to happen once, so the page renderer sets a flag on
      // the first data-view component on the page
      if (this.first) {
        this.initialiseStore()
      }
    },

    initialiseStore () {
      this.$store.commit(INITIALISE, {
        location: this.location,
        fromDate: this.fromDate.date,
        toDate: this.toDate.date,
      })
    },

    onOpenCloseDataView ({ id, closing }) {
      if (this.elementId !== id) {
        return
      }

      if (!closing) {
        this.ensureSomeSelectedStatisitics()
      }
      this.updateOpenCloseState(id, closing)
    },

    /** Set the CSS class of the section element according to whether we are opening or closing */
    updateOpenCloseState (id, closing) {
      const node = document.getElementById(id)
      const cls = node.className.replace(
        /o-data-view--(open|closed)/,
        `o-data-view--${closing ? 'closed' : 'open'}`,
      )
      node.className = cls
    },

    /** Ensure that at least one statistic is selected, or we will have an empty graph */
    ensureSomeSelectedStatisitics () {
      const stor = this.$store
      const selectedStats = stor.state.selectedStatistics

      const atLeastOneSelected
        = this.theme
          .statistics
          .map((stat) => selectedStats[stat.slug])
          .includes(true)

      if (!atLeastOneSelected) {
        // if none are currently selected, select them all
        this.availableStatistics.forEach((stat) => stor.commit(
          SELECT_STATISTIC,
          { slug: stat.slug, isSelected: true },
        ))
      }
    },

    onCompareSelect () {
      const selectedStatiticFromSlug = (stat) => this.$store.state.selectedStatistics[stat.slug]
      const statistic
        = _.find(this.availableStatistics, selectedStatiticFromSlug)

      if (statistic) {
        bus.$emit('selectComparison', {
          indicator: this.indicator,
          statistic,
        })
      }
    },
  },

  store,
}
</script>
