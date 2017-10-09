<template lang="html">
  <span v-if='location' class='o-data-view__js-options-location'>
    <a href='#' @click='onChangeLocation'>
      {{ location.labels.en }}
      <i class='fa fa-edit'></i>
    </a>
  </span>
</template>

<script>
export default {
  data: () => ({
  }),

  computed: {
    location() {
      return this.$store.state.location;
    },
  },

  mounted() {
  },

  methods: {
    onChangeLocation() {
      this.$message('This is how the user will change the location');
    },
  },
};
</script>

<style lang="scss">
</style>
