<template lang="html">
  <div class='o-data-view__vue-root u-js-only'>
    We are devo
  </div>
</template>

<script>
import kebabCase from 'kebab-case';

export default {
  data: () => ({
    theme: null,
    indicator: null,
    location: null,
    fromDate: null,
    toDate: null,
  }),

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
