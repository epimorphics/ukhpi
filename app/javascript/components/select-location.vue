<template lang='html'>
  <focus-trap v-model='showDialog' :initial-focus='initialFocusElement'>
    <div class='o-select-location'>
      <el-dialog
        :title='title'
        :visible.sync='showDialog'
        :show-close='true'
        @close='notifyDialogClosed'
      >
        <el-row>
          <el-col :span='24'>
            <p>
              {{ prompt }}
            </p>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span='24'>
            <label>
              {{ $t('js.location.search_locations_label') }}
              <el-input
                v-model='searchInput'
                @change='onSearchInput'
                @keyup.native='onSearchKeyUp'
                :autofocus='true'
                ref='searchInputField'
              >
              </el-input>
            </label>
          </el-col>
          <el-col :span='24'>
            <el-popover
              placement='bottom'
              :title='$t("js.location.results")'
              width='400'
              trigger='manual'
              v-model='searchResultsVisible'
            >
              <ul v-for='result in searchResults' class='o-search-location__results'>
                <li class='o-search-location__result'>
                  <el-button type='text' @click='onSelectResult'>
                    {{ result.labels[$locale] }}
                  </el-button>
                  ({{ result | locationTypeLabel }})
                </li>
              </ul>
              <p v-if='manyResults > 0'>
                {{ $t("js.location.many_results", { manyResults }) }}
              </p>
            </el-popover>
          </el-col>
          <el-alert type='warning' :title='noMatch' v-if='noMatch'></el-alert>
        </el-row>

        <el-row>
          <p v-if='validationMessage'>
            <el-alert
              :title='validationMessage'
              type='warning'>
            </el-alert>
          </p>
        </el-row>

        <el-row>
          <div class='c-map'>
            <div>
              {{ $t("js.location.show_on_map") }}
              <el-radio-group v-model='locationType'>
                <el-radio-button label='country'>{{ $t("js.location.type_countries") }}</el-radio-button>
                <el-radio-button label='la'>{{ $t("js.location.type_las") }}</el-radio-button>
                <el-radio-button label='region'>{{ $t("js.location.type_regions_england") }}</el-radio-button>
                <el-radio-button label='county'>{{ $t("js.location.type_counties_england") }}</el-radio-button>
              </el-radio-group>
            </div>
            <div :id='mapElementId'></div>
          </div>
        </el-row>

        <span slot='footer' class='dialog-footer'>
          <el-button @click='onHideDialog'>{{ $t('js.action.cancel') }}</el-button>
          <el-button
            type='primary'
            @click='onSaveChanges'
            :disabled='!allowConfirm'
          >{{ $t('js.action.confirm') }}</el-button>
        </span>
      </el-dialog>
    </div>
  </focus-trap>
</template>

<script>
import _ from 'lodash';
import { FocusTrap } from 'focus-trap-vue'
import { locationIndexType, locationsNamed, findLocationById } from '../lib/locations';
import LocationsMap from '../presenters/locations-map';
import { SET_LOCATION } from '../store/mutation-types';
import bus from '../lib/event-bus';

const MAX_RESULTS = 10;

export default {
  components: {
    FocusTrap
  },

  data: () => ({
    showDialog: false,
    locationType: 'country',
    selectedLocation: null,
    validationMessage: null,
    searchInput: '',
    manyResults: 0,
    searchResults: [],
    searchResultsVisible: false,
    leafletMap: null,
    noMatch: false
  }),

  props: {
    dialogVisible: {
      required: true,
      type: Boolean,
    },
    elementId: {
      required: true,
      type: String,
    },
    prompt: {
      required: false,
      type: String,
      default: function () { return this.$t('js.location.default_prompt')},
    },
    title: {
      required: false,
      type: String,
      default: function () { return this.$t('js.location.default_title') },
    },
    emitEvent: {
      required: false,
      type: String,
    },
  },

  computed: {
    allowConfirm() {
      return this.selectedLocation;
    },

    mapElementId() {
      return `${this.elementId}__map`;
    }
  },

  watch: {
    dialogVisible() {
      this.showDialog = this.dialogVisible;

      if (this.dialogVisible) {
        this.leafletMap = this.leafletMap || new LocationsMap(this.mapElementId);

        this.resetDialog();
        const cb = _.bind(this.onSelectLocationURI, this);
        this.$nextTick(() => { this.leafletMap.showMap(this.locationType, cb); });
      }
    },

    locationType() {
      const cb = _.bind(this.onSelectLocationURI, this);
      this.leafletMap.showMap(this.locationType, cb);
    },

    selectedLocation() {
      if (this.selectedLocation) {
        this.locationType = locationIndexType(this.selectedLocation);
        this.$nextTick(() => { this.leafletMap.setSelectedLocationMap(this.selectedLocation); });
      }
    },

    searchResults() {
      this.searchResultsVisible = this.searchResults && this.searchResults.length > 0;
      if (this.searchResults && this.searchResults.length === 0 &&
          this.searchInput.length > 1 && !this.selectedLocation) {
        this.noMatch = `Sorry, no locations match '${this.searchInput}'.`;
      }
    },
  },

  methods: {
    resetDialog() {
      this.selectedLocation = null;
      this.searchInput = '';
      this.manyResults = 0;
      this.searchResults = [];
      this.noMatch = null
    },

    initialFocusElement () {
      return this.$refs.searchInputField
    },

    onSaveChanges() {
      if (this.selectedLocation) {
        this.validationMessage = null;

        if (this.emitEvent) {
          bus.$emit(this.emitEvent, this.selectedLocation);
        } else {
          this.$store.commit(SET_LOCATION, this.selectedLocation);
        }

        this.onHideDialog();
      } else {
        this.validationMessage =
          `Sorry, '${this.selectedLocation}' is not a recognised location of type '${this.locationType}'`;
      }
    },

    onHideDialog() {
      this.showDialog = false;
    },

    onSelectLocationURI(uri) {
      const locationAndType = findLocationById(uri, 'uri');
      this.selectedLocation = locationAndType.location;
      this.searchInput = locationAndType.location.labels[this.$locale];
      this.noMatch = null;
    },

    isForthcomingLocation(location) {
      return !_.isEmpty(location.message)
    },

    isExactMatch(term, results) {
      const termLC = term.toLocaleLowerCase();
      const location = results && results.find(result => result.labels[this.$locale].toLocaleLowerCase() === termLC);

      return location && !this.isForthcomingLocation(location) ? location : null
    },

    setFoundLocation(location) {
      this.$set(this, 'selectedLocation', location);

      if (location) {
        this.$set(this, 'searchResults', []);
        this.$set(this, 'searchInput', location.labels[this.$locale]);
      }
    },

    showForthcoming(results) {
      console.log("showForthcoming", results)
      if (results.length === 1 && this.isForthcomingLocation(results[0])) {
        this.manyResults = 0
        this.searchResults = null
        this.noMatch = results[0].message
        console.log("shown Forthcoming")
      }
    },

    onSearchInput(term) {
      const trimmedTerm = term.trim();
      const filtered = locationsNamed(trimmedTerm);
      const match = this.isExactMatch(trimmedTerm, filtered);

      this.setFoundLocation(match);

      if (!match && filtered) {
        this.manyResults = filtered.length - MAX_RESULTS;
        this.searchResults = filtered.slice(0, MAX_RESULTS);
        this.showForthcoming(filtered)
      }
    },

    onSearchKeyUp(event) {
      this.noMatch = null

      if (event.code === 'Enter') {
        if (this.selectedLocation) {
          // enter acts as confirm if we have a selected location
          this.onSaveChanges();
        } else {
          // enter can short-cut making a selection from the list
          let match = null;

          if (this.searchResults.length === 1) {
            // have exactly one search result
            [match] = this.searchResults;
          } else {
            match = this.isExactMatch(this.searchInput, this.searchResults);
          }

          if (match) {
            this.setFoundLocation(match);
          }
        }
      } else {
        this.onSearchInput(this.searchInput);
      }
    },

    /** User has selected an autocomplete option */
    clearValidation() {
      this.validationMessage = null;
    },

    /** Notify the parent container that the dialog has closed */
    notifyDialogClosed() {
      this.$emit('update:dialog-visible', false);
    },

    onSelectResult(event) {
      this.searchInput = event.target.innerText;
      this.onSearchInput(this.searchInput);
    },
  },

  filters: {
    locationTypeLabel(location) {
      const typeName = locationIndexType(location);
      return typeName === 'la' ? 'local authority' : typeName;
    },
  },

  mounted() {
  },
};
</script>

<style lang='scss'>
</style>
