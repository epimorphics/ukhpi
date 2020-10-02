<template lang='html'>
  <div class='c-compare__selections'>
    <el-row>
      <el-col :span='24'>
        <label>
          {{ $t('js.compare.compare_action') }}
          <el-select v-model='indicatorSlug'>
            <el-option
              v-for='item in indicators'
              :key='item.slug'
              :label='item.label'
              :value='item.slug'
              :disabled='isDisabledIndicator(item.slug)'>
            </el-option>
          </el-select>
        </label>
        <label>
          {{ $t('preposition.for') }}
          <el-select v-model='statisticSlug'>
            <el-option-group
              v-for='theme in themes'
              :key='theme.slug'
              :label='theme.label'>
              <el-option
                v-for='item in theme.statistics'
                :key='item.slug'
                :label='item.label'
                :value='item.slug'
                :disabled='isDisabledStatistic(item.slug)'>
              </el-option>
            </el-option-group>
          </el-select>
        </label>
        {{ $t('preposition.from') }}
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
        {{ $t('js.compare.for_locations') }}
        <ul class='c-compare__locations'>
          <li v-for='location in locations' :key='location.slug' class='c-compare__location'>
            {{ location.labels[$locale] }}
            <button @click='onRemoveLocation(location)' class='c-compare__locations--modify' :title="$t('action.remove')" :aria-label="$t('action.remove')">
              <i class='fa fa-times-circle fa-2x'></i>
            </button>
          </li>
          <li v-if='showAddLocationButton' class='c-compare__location'>
            <button class='u-full-width c-compare__locations--modify' @click='onAddLocation' :title="$t('action.add_location')" :aria-label="$t('action.add_location')">
              <i class='fa fa-plus-circle fa-2x'></i>
            </button>
            <compare-additional-location></compare-additional-location>
          </li>
        </ul>
      </el-col>
    </el-row>
    <el-row>
      <el-col :span='24' v-if='oneOrMoreLocations'>
        <compare-locations-table
          v-if='statisticSlug && indicatorSlug'
          :statistic='statistic'
          :indicator='indicator'
          :locations='locations'
        >
        </compare-locations-table>
        <div class='c-compare__actions'>
          <div class='c-compare__print'>
            <a :href='printUrl' target='_' class='c-compare__print-link o-print-action'>
              <i class='fa fa-print'></i> {{ $t('js.action.print_table') }}
            </a>
          </div>
          <div class='c-compare__download'>
            <div>
              {{ $t('js.action.download_data_as') }}
              &nbsp;
            </div>
            <div>
              <a :href='downloadUrlCsv' class='c-compare__download-link c-compare__download-csv'>
                {{ $t('js.compare.csv_format') }} <i class='fa fa-external-link'></i>
              </a>
              <a :href='downloadUrlJson' class='c-compare__download-link c-compare__download-json'>
                {{ $t('js.compare.json_format') }} <i class='fa fa-external-link'></i>
              </a>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :span='24' v-else>
        <p>
          <em>Please select one or more locations</em>
        </p>
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
import unavailable from '../models/ukhpi-cube-metadata';

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
      compareIndicator: initialData.in,
      compareStatistic: initialData.st,
    });
    this.themes = initialData.themes;
    this.indicators = initialData.indicators;
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

    oneOrMoreLocations() {
      return this.locations.length > 0;
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

    selectedStatIndicator() {
      return {
        stat: this.$store.state.compareStatistic,
        ind: this.$store.state.compareIndicator,
      };
    },

    pathOptions() {
      const options = {
        from: this.fromDateISO,
        to: this.toDateISO,
        location: this.locationSlugs,
      };

      if (this.statistic) { options['st[]'] = this.statistic.slug; }
      if (this.indicator) { options['in[]'] = this.indicator.slug; }

      return options;
    },

    downloadUrlJson() {
      return Routes.newDownloadPath(Object.assign({ format: 'json' }, this.pathOptions));
    },

    downloadUrlCsv() {
      return Routes.newDownloadPath(Object.assign({ format: 'csv' }, this.pathOptions));
    },

    printUrl() {
      const options = { print: true };
      Object.assign(options, this.pathOptions);

      // this is a horrible hack, it has to do with the expectations on params for the
      // compare and download controllers
      Object.assign(options, {
        'st[]': null,
        'in[]': null,
        st: this.statistic.slug,
        in: this.indicator.slug,
      });

      options.lang = window.ukhpi.locale

      return Routes.comparePath(options);
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

    /** When the statistic and indicator change in the store, update the data
     * (but only if there is a difference). This typically occurs when the store
     * is updated via the 'back' operation */
    selectedStatIndicator() {
      const { stat, ind } = this.selectedStatIndicator;
      if (this.statisticSlug !== stat) {
        this.statisticSlug = stat;
      }
      if (this.indicatorSlug !== ind) {
        this.indicatorSlug = ind;
      }
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

    /**
     * Check if an indicator should be shown as disabled, because the combination
     * of the indicator with the currently selected statistic is unavailable
     * @param  {String}  ind indicator slug
     * @return {Boolean}     True if the indicator should be shown as disabled
     */
    isDisabledIndicator(ind) {
      return unavailable(this.statisticSlug, ind);
    },

    /**
     * Check if a statistic should be shown as disabled, because the combination
     * of the statistic with the currently selected indicator is unavailable
     * @param  {String}  ind statistic slug
     * @return {Boolean}     True if the statistic should be shown as disabled
     */
    isDisabledStatistic(stat) {
      return unavailable(stat, this.indicatorSlug);
    },
  },
};
</script>

<style lang='scss'>
</style>
