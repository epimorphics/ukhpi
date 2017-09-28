<template lang="html">
  <div class='o-data-view__vue-root u-js-only'>
    <data-view-location :initial-location='location'></data-view-location>
  </div>
</template>

<script>
import kebabCase from 'kebab-case';
import DataViewLocation from './components/data-view-location.vue';

export default {
  data: () => ({
    theme: null,
    indicator: null,
    location: null,
    fromDate: null,
    toDate: null,
  }),

  components: {
    DataViewLocation,
  },

  beforeMount() {
    const attrs = this.$el.attributes;

    for (let i = 0; i < attrs.length; i += 1) {
      const attr = attrs.item(i);

      if (attr.name.match(/^data-/)) {
        const name = kebabCase.reverse(attr.name.replace(/^data-/, ''));
        const value = JSON.parse(attr.value);
        this.$set(this, name, value);
      }
    }
  },
};
</script>

<style lang="scss">
</style>
