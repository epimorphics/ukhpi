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
        from
        <data-view-dates />
      </el-col>
    </el-row>
    <el-row>
      <el-col :span='24'>
        For locations:
        <ul class='compare__locations'>
          <li v-for='location in locations' :key='location.slug' class='c-compare__location'>
            {{ location.labels.en }}
            <button @click='onRemoveLocation(location)'><i class='fa fa-close'></i></button>
          </li>
        </ul>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import kebabCase from 'kebab-case';
import _ from 'lodash';
import { SET_COMPARE_LOCATIONS, SET_COMPARE_STATISTIC,
  SET_COMPARE_INDICATOR, SET_DATES } from '../store/mutation-types';

import DataViewDates from './data-view-dates.vue';

export default {
  data: () => ({
    statistic: null,
    indicator: null,
    indicators: [],
    themes: [],
  }),

  components: {
    DataViewDates,
  },

  mounted() {
    const node = document.querySelector('.c-location-compare__data');
    const attrs = node.attributes;
    const initialData = {};

    for (let i = 0; i < attrs.length; i += 1) {
      const attr = attrs.item(i);

      if (attr.name.match(/^data-/)) {
        const name = kebabCase.reverse(attr.name.replace(/^data-/, ''));
        let value = JSON.parse(attr.value);

        if (value.date) {
          value = new Date(value.date);
        }

        initialData[name] = value;
      }
    }

    this.$store.commit(SET_DATES, initialData);
    this.$store.commit(SET_COMPARE_LOCATIONS, initialData.locations);
    this.themes = initialData.themes;
    this.indicators = initialData.indicators;
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

    locations() {
      return this.$store.state.compareLocations;
    },
  },

  watch: {
    indicators() {
      const selIndicator = this.indicators.find(indicator => indicator.isSelected).slug;
      this.indicator = selIndicator;
      this.$store.commit(SET_COMPARE_INDICATOR, selIndicator);
    },

    statistics() {
      const selStatistic = this.statistics.find(statistic => statistic.isSelected).slug;
      this.statistic = selStatistic;
      this.$store.commit(SET_COMPARE_STATISTIC, selStatistic);
    },
  },

  methods: {
    onRemoveLocation(toRemoveLocation) {
      const newLocations = this.locations.filter(location => location.gss !== toRemoveLocation.gss);
      this.$store.commit(SET_COMPARE_LOCATIONS, newLocations);
    },
  },
};
</script>

<style lang='scss'>
</style>
