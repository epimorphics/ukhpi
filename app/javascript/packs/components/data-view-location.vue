<template lang="html">
  <div  class='o-data-view__js-options-location'>
    <span v-if='location'>
      <a href='#' @click='onChangeLocation'>
        {{ location.labels.en }}
        <i class='fa fa-edit'></i>
      </a>
    </span>

    <select-location :dialogVisible.sync='dialogVisible'></select-location>
  </div>
</template>

<script>
import SelectLocation from './select-location.vue';

export default {
  data: () => ({
    dialogVisible: false,
  }),

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
