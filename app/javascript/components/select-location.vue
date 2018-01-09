<template lang='html'>
  <div class='o-select-location'>
    <el-dialog
      :title='title'
      :visible.sync='showDialog'
      :show-close='true'
      @close='notifyDialogClosed'
    >
      <el-row>
        <el-col :span='16'>
          <p>
            {{ prompt }}
          </p>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span='24'>
          <label>
            Search locations:
            <el-input
              v-model='searchInput'
              @change='onSearchInput'
              @keyup.native='onSearchKeyUp'
              :autofocus='true'
            >
            </el-input>
          </label>
        </el-col>
        <el-col :span='24'>
          <el-popover
            placement='bottom'
            title='Search results'
            width='400'
            trigger='manual'
            v-model='searchResultsVisible'
          >
            <ul v-for='result in searchResults' class='o-search-location__results'>
              <li class='o-search-location__result'>
                <el-button type='text' @click='onSelectResult'>
                  {{ result.labels.en }}
                </el-button>
                ({{ result | locationTypeLabel }})
              </li>
            </ul>
          </el-popover>
          <p v-if='manyResults > 0'>
            ... plus {{ manyResults }} more.
          </p>
        </el-col>
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
            Show on map:
            <el-radio-group v-model='locationType'>
              <el-radio-button label='country'>Countries</el-radio-button>
              <el-radio-button label='la'>Local authorities</el-radio-button>
              <el-radio-button label='region'>Regions of England</el-radio-button>
              <el-radio-button label='county'>Counties of England</el-radio-button>
            </el-radio-group>
          </div>
          <div :id='mapElementId'></div>
        </div>
      </el-row>

      <span slot='footer' class='dialog-footer'>
        <el-button @click='onHideDialog'>Cancel</el-button>
        <el-button
          type='primary'
          @click='onSaveChanges'
          :disabled='!allowConfirm'
        >Confirm</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import _ from 'lodash';
import { locationIndexType, locationsNamed, findLocationById } from '../lib/locations';
import LocationsMap from '../presenters/locations-map';
import { SET_LOCATION } from '../store/mutation-types';
import bus from '../lib/event-bus';

const MAX_RESULTS = 10;

export default {
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
      default: 'To show UKHPI statistics for a different part of the UK, select the new location by searching on the name, or by clicking a location on the map below.',
    },
    title: {
      required: false,
      type: String,
      default: 'Choose a different region or location',
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
    },
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
    },
  },

  methods: {
    resetDialog() {
      this.selectedLocation = null;
      this.searchInput = '';
      this.manyResults = 0;
      this.searchResults = [];
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
      this.searchInput = locationAndType.location.labels.en;
    },

    isExactMatch(term, results) {
      const termLC = term.toLocaleLowerCase();
      return results &&
             results.find(result => result.labels.en.toLocaleLowerCase() === termLC);
    },

    setFoundLocation(location) {
      this.$set(this, 'selectedLocation', location);
      this.$set(this, 'searchResults', []);
      this.$set(this, 'searchInput', location.labels.en);
    },

    onSearchInput(term) {
      const filtered = locationsNamed(term);
      const match = this.isExactMatch(term, filtered);

      if (match) {
        this.setFoundLocation(match);
      } else if (filtered) {
        this.manyResults = filtered.length - MAX_RESULTS;
        this.searchResults = filtered.slice(0, MAX_RESULTS);
      }
    },

    onSearchKeyUp(event) {
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
