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
        <ul class='c-compare__locations'>
          <li v-for='location in locations' :key='location.slug' class='c-compare__location'>
            {{ location.labels.en }}
            <button @click='onRemoveLocation(location)' class='c-compare__locations--modify'>
              <i class='fa fa-times-circle fa-2x'></i>
            </button>
          </li>
          <li v-if='showAddLocationButton'>
            <button class='u-full-width c-compare__locations--modify' @click='onAddLocation'>
              <i class='fa fa-plus-circle fa-2x'></i>
            </button>
            <compare-additional-location></compare-additional-location>
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
  SET_COMPARE_INDICATOR, INITIALISE } from '../store/mutation-types';

import DataViewDates from './data-view-dates.vue';
import CompareAdditionalLocation from './compare-additional-location.vue';
import bus from '../lib/event-bus';

const MAX_LOCATIONS = 5;

export default {
  data: () => ({
    statistic: null,
    indicator: null,
    indicators: [],
    themes: [],
  }),

  components: {
    DataViewDates,
    CompareAdditionalLocation,
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

    this.$store.commit(INITIALISE, {
      fromDate: initialData.fromDate,
      toDate: initialData.toDate,
      compareLocations: initialData.locations,
    });
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

    /** We can still add a location if the current list is strictly less than
     * the ultimate limit, giving room for one last addition */
    showAddLocationButton() {
      return this.locations.length < MAX_LOCATIONS;
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

    onAddLocation() {
      bus.$emit('select-comparison');
    },
  },
};
</script>

<style lang='scss'>
</style>
