<template>
  <div class="c-options-selection__location">
    <span v-if="location">
      <ElButton
        class="c-options-selection__button"
        :title="$t('js.action.select_location')"
        @click="onChangeLocation"
      >
        {{ location.labels[$locale] || location.labels.en }}
        <i class="fa fa-edit" />
      </ElButton>
    </span>

    <SelectLocation
      :dialog-visible="dialogVisible"
      :element-id="elementId"
      @update:dialog-visible="val => dialogVisible = val"
    />
  </div>
</template>

<script>
import SelectLocation from './select-location.vue'
import bus from '@/lib/event-bus'

export default {

  components: {
    SelectLocation,
  },

  props: {
    elementId: {
      required: true,
      type: String,
    },
  },
  data: () => ({
    dialogVisible: false,
  }),

  computed: {
    location () {
      return this.$store.state.location
    },
  },

  mounted () {
    bus.$on('change-location', this.onChangeLocation)
  },

  methods: {
    onChangeLocation () {
      this.dialogVisible = true
    },
  },
}
</script>
