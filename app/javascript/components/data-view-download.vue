<template lang='html'>
  <div class='o-data-view-download'>
    <el-row>
      <el-col :span='18'>
        <p
          v-html="$t('js.download.prompt', { qonsolePath: this.qonsolePath })"
        />

        <ul>
          <li>
            <span v-html="$t('js.download.selected', { themeName: this.themeName, indicatorName: this.indicatorName, locationName: this.locationName })" />
            <br />
            <a class='o-data-view-download__button' :href='downloadUrl("csv", true, true)'>
              {{ $t('js.download.csv_prompt')}} <i class='fa fa-external-link'></i>
            </a>
            <a class='o-data-view-download__button' :href='downloadUrl("json", true, true)'>
              {{ $t('js.download.json_prompt') }} <i class='fa fa-external-link'></i>
            </a>
          </li>
          <li>
            <span v-html="$t('js.download.theme', { themeName: this.themeName, locationName: this.locationName })" />
            <br />
            <a class='o-data-view-download__button' :href='downloadUrl("csv", true, false)' download>
              {{ $t('js.download.csv_prompt')}} <i class='fa fa-external-link'></i>
            </a>
            <a class='o-data-view-download__button' :href='downloadUrl("json", true, false)' download>
              {{ $t('js.download.json_prompt') }} <i class='fa fa-external-link'></i>
            </a>
          </li>
        </ul>
        <p>
          <span v-html="$t('js.download.all', { locationName: this.locationName })" />
          <br />
          <a class='o-data-view-download__button' :href='downloadUrl("csv", false, false)' download>
              {{ $t('js.download.csv_prompt')}} <i class='fa fa-external-link'></i>
          </a>
          <a class='o-data-view-download__button' :href='downloadUrl("json", false, false)' download>
              {{ $t('js.download.json_prompt') }} <i class='fa fa-external-link'></i>
          </a>

        </p>
        <p class='u-muted' v-html="$t('js.download.license')">
        </p>
      </el-col>
    </el-row>
  </div>
</template>

<script>
const Routes = require('../lib/routes.js.erb');

export default {
  props: {
    indicator: {
      required: false,
      type: Object,
    },
    theme: {
      required: true,
      type: Object,
    },
  },

  computed: {
    /**
    * The path to the qonsole application
    * @return {String} The path
    */
    qonsolePath() {
      return `${window.location.pathname.replace(/\/[^/]*\/[^/]*$/, '/qonsole')}?query=_localstore`;
    },

    fromDate() {
      return this.$store.state.fromDate;
    },

    toDate() {
      return this.$store.state.toDate;
    },

    currentLocale () {
      return window.ukhpi.locale
    },

    locationUri() {
      const { location } = this.$store.state;
      return location ? location.uri : '';
    },

    locationName() {
      const { location } = this.$store.state;
      return location ? location.labels[this.currentLocale] : '';
    },

    themeName() {
      return this.theme ? this.theme.label.toLocaleLowerCase() : '';
    },

    indicatorName() {
      return this.indicator ? this.indicator.label.toLocaleLowerCase() : '';
    },
  },

  methods: {
    /**
     * Calculate the URL for downloading a particular slice of the data
     * @param  {String} mediaType     Desired media type, e.g. json
     * @param {String} withTheme If true, include the theme as a constraint
     * @param  {Boolean} withIndicator If true, include the indicator as a constraint
     * @return {String}               The download URL
     */
    downloadUrl(mediaType, withTheme, withIndicator) {
      const options = {
        format: mediaType,
        from: this.fromDate,
        to: this.toDate,
        location: this.locationUri,
      };

      if (withTheme && this.theme) {
        options['thm[]'] = this.theme.slug;
      }

      if (withIndicator && this.indicator) {
        options['in[]'] = this.indicator.slug;
      }

      return `${Routes.newDownloadPath(options)}`;
    },
  },
};
</script>

<style lang='scss'>
</style>
