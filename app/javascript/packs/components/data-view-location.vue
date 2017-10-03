<template lang="html">
  <span v-if='location' class='o-data-view__js-options-location'>
    <a href='#'>
      {{ location.labels.en }}
      <i class='fa fa-edit'></i>
    </a>
  </span>
</template>

<script>
export default {
  data: () => ({
    location: null,
  }),

  props: [
    'initialLocation',
  ],

  mounted() {
    this.location = this.initialLocation;
  },

  watch: {
  },
};
</script>

<style lang="scss">
</style>
