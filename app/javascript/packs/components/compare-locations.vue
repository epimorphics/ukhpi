<template lang='html'>
  <div class='c-compare__selections'>
  </div>
</template>

<script>
import kebabCase from 'kebab-case';

export default {
  data: () => ({
    from: null,
    to: null,
    locations: [],
    statistic: null,
    indicator: null,
    indicators: [],
    themes: {},
  }),

  beforeMount() {
    const node = document.querySelector('.c-location-compare__data');
    const attrs = node.attributes;

    for (let i = 0; i < attrs.length; i += 1) {
      const attr = attrs.item(i);

      if (attr.name.match(/^data-/)) {
        const name = kebabCase.reverse(attr.name.replace(/^data-/, ''));
        let value = JSON.parse(attr.value);

        if (value.date) {
          value = new Date(value.date);
        }

        this.$set(this, name, value);
      }
    }
  },

  watch: {
    indicators() {
      this.indicator = this.indicators.find(indicator => indicator.isSelected);
    },

    themes() {
      this.themes.forEach((theme) => {
        theme.statistics.forEach((statistic) => {
          if (statistic.isSelected) {
            this.statistic = statistic;
          }
        });
      });
    },
  },
};
</script>

<style lang='scss'>
</style>
