<template>
  <div class="c-options-selection">
    <DataViewLocation :element-id="elementId" />
    {{ $t('preposition.for') }}
    <DataViewDates />
    <DataViewGraphZoomed />
  </div>
</template>

<script>
import DataViewLocation from './data-view-location.vue'
import DataViewDates from './data-view-dates.vue'
import DataViewGraphZoomed from './data-view-graph-zoomed.vue'
import store from '../store/index'

export default {

  components: {
    DataViewLocation,
    DataViewDates,
    DataViewGraphZoomed,
  },
  data: () => ({
    elementId: 'optionsSelection',
  }),

  store,
}
</script>
