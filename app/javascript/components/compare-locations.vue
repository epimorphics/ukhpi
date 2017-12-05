<template lang='html'>
  <div class='c-compare__selections'>
    <el-row>
      <el-col :span='24'>
        Compare
        <el-select v-model='indicatorSlug'>
          <el-option
            v-for="item in indicators"
            :key="item.slug"
            :label="item.label"
            :value="item.slug">
          </el-option>
        </el-select>
        for
        <el-select v-model='statisticSlug'>
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
      <el-col :span='24'>
        <el-alert
          type='warning'
          :title='illegalIndicatorStatisticCombo'
          v-if='illegalIndicatorStatisticCombo'
        >
        </el-alert>
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
          <li v-if='showAddLocationButton' class='c-compare__location'>
            <button class='u-full-width c-compare__locations--modify' @click='onAddLocation'>
              <i class='fa fa-plus-circle fa-2x'></i>
            </button>
            <compare-additional-location></compare-additional-location>
          </li>
        </ul>
      </el-col>
    </el-row>
    <el-row>
      <el-col :span='24'>
        <compare-locations-table
          v-if='statisticSlug && indicatorSlug'
          :statistic='statistic'
          :indicator='indicator'
          :locations='locations'
        >
        </compare-locations-table>
        <span class='c-compare__download'>
          Download this data as:
          <a href='#' class='c-compare__download-link c-compare__download-csv'>
            CSV (spreadsheet) <i class='fa fa-external-link'></i>
          </a>
          <a href='#' class='c-compare__download-link c-compare__download-json'>
            JSON <i class='fa fa-external-link'></i>
          </a>
        </span>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import kebabCase from 'kebab-case';
import _ from 'lodash';
import Moment from 'moment';
import { SET_COMPARE_LOCATIONS, SET_COMPARE_STATISTIC,
  SET_COMPARE_INDICATOR, INITIALISE } from '../store/mutation-types';

import DataViewDates from './data-view-dates.vue';
import CompareAdditionalLocation from './compare-additional-location.vue';
import CompareLocationsTable from './compare-locations-table.vue';
import bus from '../lib/event-bus';
import Routes from '../lib/routes.js.erb';

const MAX_LOCATIONS = 5;

export default {
  data: () => ({
    statisticSlug: null,
    indicatorSlug: null,
    indicators: [],
    themes: [],
  }),

  components: {
    DataViewDates,
    CompareAdditionalLocation,
    CompareLocationsTable,
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
      fromDate: initialData.from,
      toDate: initialData.to,
      compareLocations: initialData.locations,
    });
    this.themes = initialData.themes;
    this.indicators = initialData.indicators;

    this.updateDownloadURL();
  },

  computed: {
    statistic() {
      const slug = this.statisticSlug;
      return this.statistics.find(stat => stat.slug === slug);
    },

    indicator() {
      const slug = this.indicatorSlug;
      return this.indicators.find(ind => ind.slug === slug);
    },

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

    locationSlugs() {
      return this.$store.state.compareLocations.map(loc => loc.gss);
    },

    /** We can still add a location if the current list is strictly less than
     * the ultimate limit, giving room for one last addition */
    showAddLocationButton() {
      return this.locations.length < MAX_LOCATIONS;
    },

    illegalIndicatorStatisticCombo() {
      if (this.indicatorSlug === 'vol' && !this.statistic.hasVolume) {
        return 'Sorry, that combination of indicator and statistic is not available.';
      }

      return null;
    },

    toDateISO() {
      return Moment(this.$store.state.toDate).format('YYYY-MM-DD');
    },

    fromDateISO() {
      return Moment(this.$store.state.fromDate).format('YYYY-MM-DD');
    },
  },

  watch: {
    indicators() {
      const selIndicator = this.indicators.find(indicator => indicator.isSelected).slug;
      this.indicatorSlug = selIndicator;
      this.$store.commit(SET_COMPARE_INDICATOR, selIndicator);
    },

    statistics() {
      const selStatistic = this.statistics.find(statistic => statistic.isSelected).slug;
      this.statisticSlug = selStatistic;
      this.$store.commit(SET_COMPARE_STATISTIC, selStatistic);
    },

    indicatorSlug() {
      this.$store.commit(SET_COMPARE_INDICATOR, this.indicatorSlug);
    },

    statisticSlug() {
      this.$store.commit(SET_COMPARE_STATISTIC, this.statisticSlug);
    },

    // when the selections change, morph the data download URL...

    fromDate() {
      this.updateDownloadURL();
    },
    toDate() {
      this.updateDownloadURL();
    },
    indicator() {
      this.updateDownloadURL();
    },
    statistic() {
      this.updateDownloadURL();
    },
    locations() {
      this.updateDownloadURL();
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

    updateDownloadURL() {
      const pathOptions = {
        from: this.fromDateISO,
        to: this.toDateISO,
        st: this.statistic.slug,
        in: this.indicator.slug,
        location: this.locationSlugs,
      };

      const hrefJson = Routes.newDownloadPath(Object.assign({ format: 'json' }, pathOptions));
      const hrefCsv = Routes.newDownloadPath(Object.assign({ format: 'csv' }, pathOptions));

      let anchorElement = document.querySelector('.c-compare__download-json');
      anchorElement.setAttribute('href', hrefJson);

      anchorElement = document.querySelector('.c-compare__download-csv');
      anchorElement.setAttribute('href', hrefCsv);
    },
  },
};
</script>

<style lang='scss'>
</style>
