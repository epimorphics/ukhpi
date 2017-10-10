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
          <label>
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
import { locationNamed, locationsNamed } from '../lib/locations';
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
  },

  computed: {
    allowConfirm() {
      return this.selectedLocation !== null && this.selectedLocation.length > 0;
    },
  },

  watch: {
    dialogVisible() {
      this.showDialog = this.dialogVisible;
    },
  },

  methods: {
    onSaveChanges() {
      const loc = locationNamed(this.locationType, this.selectedLocation);
      if (loc) {
        this.validationMessage = null;
        this.$store.commit(SET_LOCATION, loc);
        this.onHideDialog();
      } else {
        this.validationMessage =
          `Sorry, '${this.selectedLocation}' is not a recognised location of type '${this.locationType}'`;
      }
    },

    onHideDialog() {
      this.showDialog = false;
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
};
</script>

<style lang='scss'>
</style>
