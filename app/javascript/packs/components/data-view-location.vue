<template lang="html">
  <div  class='o-data-view__js-options-location'>
    <span v-if='location'>
      <a href='#' @click='onChangeLocation'>
        {{ location.labels.en }}
        <i class='fa fa-edit'></i>
      </a>
    </span>

    <select-location
      :dialog-visible='dialogVisible'
      :element-id='elementId'
      @update:dialog-visible='val => dialogVisible = val'
    ></select-location>
  </div>
</template>

<script>
import SelectLocation from './select-location.vue';

export default {
  data: () => ({
    dialogVisible: false,
  }),

  props: {
    elementId: {
      required: true,
      type: String,
    },
  },

  computed: {
    location() {
      return this.$store.state.location;
    },
  },

  components: {
    SelectLocation,
  },

  mounted() {
  },

  methods: {
    onChangeLocation() {
      this.dialogVisible = true;
    },
  },
};
</script>

<style lang="scss">
</style>
