<template>
  <SelectLocation
    :dialog-visible="dialogVisible"
    :element-id="elementId"
    :prompt="prompt"
    :title="$t('js.action.choose_another_location')"
    emit-event="additional-location-selected"
    @update:dialog-visible="val => dialogVisible = val"
  />
</template>

<script>
import _ from 'lodash'
import SelectLocation from './select-location.vue'
import store from '@/store/index'
import { SET_COMPARE_LOCATIONS } from '@/store/mutation-types'
import bus from '@/lib/event-bus'

export default {

  components: {
    SelectLocation,
  },
  data: () => ({
    elementId: 'comparisonSelection',
    dialogVisible: false,
  }),

  computed: {
    prompt () {
      return 'Select an additional area to compare'
    },
  },

  mounted () {
    bus.$on('selectComparison', this.onSelectComparison)
    bus.$on('additional-location-selected', this.onAdditionalLocation)
  },

  methods: {
    onSelectComparison () {
      this.dialogVisible = true
    },

    onAdditionalLocation (location) {
      const newLocations = this.$store.state.compareLocations.concat([location])
      const uniqLocations = _.uniqBy(newLocations, 'gss')
      this.$store.commit(SET_COMPARE_LOCATIONS, uniqLocations)
    },
  },

  store,
}
</script>
