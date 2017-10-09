<template lang='html'>
  <div class='o-select-location'>
    <el-dialog
      title='Choose a different region or location'
      :visible.sync='showDialog'
      :show-close='true'
    >
      <el-row>
        <el-col :span='16'>
          <p>
            To show UKHPI statistics for a different part of the UK, select the new
            location by searching on the name, or by clicking a location on the map
            below.
          </p>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span='8'>
          <label>
            Location type:
            <el-select v-model='locationType'>
              <el-option value='country' label='Country' />
              <el-option value='la' label='Local authority' />
              <el-option value='region' label='Region (England only)' />
              <el-option value='county' label='County (England only)' />
            </el-select>
          </label>
        </el-col>
        <el-col :span='16'>
          <label>
            Location name:
            <el-autocomplete
              class='inline-input u-full-width'
              v-model='selectedLocation'
              :fetch-suggestions='queryLocation'
              :trigger-on-focus='false'
              :select-when-unmatched='false'
              @input='clearValidation'
            >
            </el-autocomplete>
          </label>
        </el-col>
        <el-col :span='8'>
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

      <span slot='footer' class='dialog-footer'>
        <el-button @click='showDialog = false'>Cancel</el-button>
        <el-button type='primary' @click='onSaveChanges'>Confirm</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import _ from 'lodash';
import { locations } from '../lib/regions-table';

export default {
  data: () => ({
    showDialog: false,
    locationType: 'country',
    selectedLocation: null,
    locationsIndex: {
      country: {},
      la: {},
      region: {},
      county: {},
    },
    validationMessage: null,
  }),

  props: {
    dialogVisible: {
      required: true,
      type: Boolean,
    },
  },

  watch: {
    dialogVisible() {
      this.showDialog = this.dialogVisible;
    },
  },

  methods: {
    onSaveChanges() {
      const loc = this.locationsIndex[this.locationType][this.selectedLocation];
      if (loc) {
        this.validationMessage = null;
      } else {
        this.validationMessage =
          `Sorry, '${this.selectedLocation}' is not a recognised location of type '${this.locationType}'`;
      }
    },

    queryLocation(query, cb) {
      const candidates = _.keys(this.locationsIndex[this.locationType]);
      const regex = new RegExp(query, 'i');
      const filtered = candidates.filter(candidate => candidate.match(regex));
      const values = filtered.map(v => ({ value: v }));
      cb(values);
    },

    /** Which inddex should this location go into? */
    locationIndexType(location) {
      const name = location.labels.en;

      switch (location.type) {
        case 'http://data.ordnancesurvey.co.uk/ontology/admingeo/EuropeanRegion':
          return (name === 'England' || name.match(/(wales|scotland|ireland)/i)) ? 'country' : 'region';

        case 'http://data.ordnancesurvey.co.uk/ontology/admingeo/County':
          return 'county';

        default:
          // assume all other types are synonyms for local authority
          return 'la';
      }
    },

    /** Create an inverted index of names to locations, that we can use in search */
    indexLocations() {
      const index = this.locationsIndex;
      const vm = this;

      _.each(Object.values(locations), (location) => {
        const name = location.labels.en;
        index[vm.locationIndexType(location)][name] = location;
      });
    },

    /** User has selected an autocomplete option */
    clearValidation() {
      this.validationMessage = null;
    },
  },

  mounted() {
    this.indexLocations();
  },
};
</script>

<style lang='scss'>
</style>
