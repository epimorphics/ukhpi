<template lang='html'>
  <div class='c-compare__selections'>
    <el-row>
      <el-col :span='24'>
        Compare
        <el-select v-model='indicator'>
          <el-option
            v-for="item in indicators"
            :key="item.slug"
            :label="item.label"
            :value="item.slug">
          </el-option>
        </el-select>
        for
        <el-select v-model='statistic'>
          <el-option-group
            v-for="theme in themes"
            :key="theme.slug"
            :label="theme.label">
            <el-option
              v-for="item in theme.statistics"
              :key="item.slug"
              :label="item.label"
              :value="item.slug">
            </el-option>
          </el-option-group>
        </el-select>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import kebabCase from 'kebab-case';
import _ from 'lodash';

export default {
  data: () => ({
    from: null,
    to: null,
    locations: [],
    statistic: null,
    indicator: null,
    indicators: [],
    themes: [],
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

  computed: {
    statistics() {
      function statWithGroup(theme, stat) {
        return Object.assign({ theme: theme.label }, stat);
      }

      function themeStats(theme) {
        return theme.statistics.map(stat => statWithGroup(theme, stat));
      }

      return _.flatten(this.themes.map(themeStats));
    },
  },

  watch: {
    indicators() {
      this.indicator = this.indicators.find(indicator => indicator.isSelected).slug;
    },

    statistics() {
      this.statistic = this.statistics.find(statistic => statistic.isSelected).slug;
    },
  },
};
</script>

<style lang='scss'>
</style>
