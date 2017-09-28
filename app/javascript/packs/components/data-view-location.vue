<template lang="html">
  <span v-if='location'>
    {{ location.labels.en }}
    <el-button size='small'>
      <i class='fa fa-edit'></i>
    </el-button>
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
