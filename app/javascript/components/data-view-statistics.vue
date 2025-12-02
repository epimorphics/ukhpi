<template>
  <div class="o-data-view__js-options-statistics">
    <label
      v-for="(statistic, index) in statistics"
      :key="statistic.slug"
      class="checkbox-container"
    >
      <input
        type="checkbox"
        :name="statistic.label"
        :data-slug="statistic.slug"
        :checked="isSelectedStatistic(statistic.slug)"
        @change="onSelectStatistic"
        @keydown.enter="onSelectStatistic"
      >
      <img
        :src="imageSrcPath(index, false)"
        :srcset="imageSrcPath(index, true)"
        :alt="`marker image for ${statistic.label}`"
      >
      {{ statistic.label }}
    </label>
  </div>
</template>

<script>
import { SELECT_STATISTIC } from '../store/mutation-types'
import markerRoutes from '../images/markers/'

const MARKERS = [
  'Circle',
  'Diamond',
  'Square',
  'Star',
  'Triangle',
]

export default {

  props: {
    initialStatistics: {
      type: Array,
      required: true,
    },
    zoom: {
      type: Boolean,
      required: true,
    },
  },
  data: () => ({
    statistics: [],
  }),

  mounted () {
    this.initStatistics()
  },

  methods: {
    initStatistics () {
      if (this.statistics !== this.initialStatistics) {
        this.statistics = this.initialStatistics
      }
      if (!this.zoom) {
        this.syncSelectedStatisticsToStore()
      }
    },

    syncSelectedStatisticsToStore () {
      const store = this.$store
      this.initialStatistics.forEach((stat) => {
        store.commit(SELECT_STATISTIC, { slug: stat.slug, isSelected: stat.isSelected })
      })
    },

    onSelectStatistic (event) {
      const slug = event.target.getAttribute('data-slug')
      const selected = this.isSelectedStatistic(slug)
      this.$store.commit(SELECT_STATISTIC, { slug, isSelected: !selected })
    },

    isSelectedStatistic (slug) {
      return this.$store.state.selectedStatistics[slug]
    },

    imageSrcPath (index, svg) {
      const imageRoot = MARKERS[index]
      const imagePathKey = `marker${imageRoot}${svg ? 'Svg' : ''}`
      return new URL(`../${markerRoutes[imagePathKey]}`, import.meta.url).pathname
    },
  },
}
</script>
