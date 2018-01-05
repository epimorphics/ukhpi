<template lang="html">
  <div  class='c-options-selection__location'>
    <span v-if='location'>
      <el-button
        @click='onChangeLocation'
        class='c-options-selection__button'
        title='select a diffent location'
      >
        {{ location.labels.en }}
        <i class='fa fa-edit'></i>
      </el-button>
    </span>

    <select-location
      :dialog-visible='dialogVisible'
      :element-id='elementId'
      @update:dialog-visible='val => dialogVisible = val'
    ></select-location>
  </div>
</template>

<script>
import SelectLocation from './select-location.vue';
import bus from '../lib/event-bus';

export default {
  data: () => ({
    dialogVisible: false,
  }),

  props: {
    elementId: {
      required: true,
      type: String,
    },
  },

  computed: {
    location() {
      return this.$store.state.location;
    },
  },

  components: {
    SelectLocation,
  },

  mounted() {
    bus.$on('change-location', this.onChangeLocation);
  },

  methods: {
    onChangeLocation() {
      this.dialogVisible = true;
    },
  },
};
</script>

<style lang="scss">
</style>
