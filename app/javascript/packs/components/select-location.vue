<template lang='html'>
  <div class='o-select-location'>
    <el-dialog
      title='Choose a different region or location'
      :visible.sync='showDialog'
      :show-close='true'
      @close='notifyDialogClosed'
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
            Type of location:
            <el-select v-model='locationType'>
              <el-option value='country' label='Country' />
              <el-option value='la' label='Local authority' />
              <el-option value='region' label='Region (England only)' />
              <el-option value='county' label='County (England only)' />
            </el-select>
          </label>
        </el-col>
        <el-col :span='16'>
          <label v-if='locationType === "country"'>
            <br />
            <el-select v-model='selectedLocation'>
              <el-option value='United Kingdom'></el-option>
              <el-option value='Great Britain'></el-option>
              <el-option value='England and Wales'></el-option>
              <el-option value='England'></el-option>
              <el-option value='Wales'></el-option>
              <el-option value='Scotland'></el-option>
              <el-option value='Northern Ireland'></el-option>
            </el-select>
          </label>
          <label v-else>
            Name:
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

      <el-row>
        <div class='c-map'>
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
import { locationNamed, locationsNamed, findLocationById } from '../lib/locations';
import { showMap, setSelectedLocationMap } from '../presenters/locations-map';
import { SET_LOCATION } from '../store/mutation-types';

export default {
  data: () => ({
    showDialog: false,
    locationType: 'country',
    selectedLocation: null,
    validationMessage: null,
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
  },

  computed: {
    allowConfirm() {
      return this.selectedLocation !== null && this.selectedLocation.length > 0;
    },

    mapElementId() {
      return `${this.elementId}__map`;
    },

    selectedLocationData() {
      return locationNamed(this.locationType, this.selectedLocation);
    },
  },

  watch: {
    dialogVisible() {
      this.showDialog = this.dialogVisible;

      if (this.dialogVisible) {
        const cb = _.bind(this.onSelectLocationURI, this);
        this.$nextTick(() => { showMap(this.mapElementId, this.locationType, cb); });
      }
    },

    locationType() {
      const cb = _.bind(this.onSelectLocationURI, this);
      showMap(this.mapElementId, this.locationType, cb);
    },

    selectedLocationData() {
      if (this.selectedLocationData) {
        setSelectedLocationMap(this.selectedLocationData);
      }
    },
  },

  methods: {
    onSaveChanges() {
      if (this.selectedLocationData) {
        this.validationMessage = null;
        this.$store.commit(SET_LOCATION, this.selectedLocationData);
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
      this.selectedLocation = locationAndType.location.labels.en;
    },

    queryLocation(query, cb) {
      const filtered = locationsNamed(this.locationType, query);
      cb(filtered.map(v => ({ value: v })));
    },

    /** User has selected an autocomplete option */
    clearValidation() {
      this.validationMessage = null;
    },

    /** Notify the parent container that the dialog has closed */
    notifyDialogClosed() {
      this.$emit('update:dialog-visible', false);
    },
  },

  mounted() {
  },
};
</script>

<style lang='scss'>
</style>
