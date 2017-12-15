<template lang='html'>
  <div class='o-data-view-download'>
    <el-row>
      <el-col :span='18'>
        <p>
          You can download this data, so that you can process it further yourself.
          You can also <a :href='qonsolePath'>try the SPARQL query</a>.
        </p>
        <ul>
          <li>
            Download only <strong>{{ indicatorName }}</strong>
            by <strong>{{ themeName }}</strong>
            in {{ locationName }}:
            <br />
            <a class='o-data-view-download__button' :href='downloadUrl("csv", true, true)'>
              download CSV/spreadsheet <i class='fa fa-external-link'></i>
            </a>
            <a class='o-data-view-download__button' :href='downloadUrl("json", true, true)'>
              download JSON <i class='fa fa-external-link'></i>
            </a>
          </li>
          <li>
            Download <strong>all</strong> of index, average and percentage change
            by <strong>{{ themeName }}</strong>
            in {{ locationName }}:
            <br />
            <a class='o-data-view-download__button' :href='downloadUrl("csv", true, false)' download>
              download CSV/spreadsheet <i class='fa fa-external-link'></i>
            </a>
            <a class='o-data-view-download__button' :href='downloadUrl("json", true, false)' download>
              download JSON <i class='fa fa-external-link'></i>
            </a>
          </li>
        </ul>
        <p>
          Download
          <strong>all UKHPI data</strong> for {{ locationName }} for this period:
          <br />
          <a class='o-data-view-download__button' :href='downloadUrl("csv", false, false)' download>
            download CSV/spreadsheet <i class='fa fa-external-link'></i>
          </a>
          <a class='o-data-view-download__button' :href='downloadUrl("json", false, false)' download>
            download JSON <i class='fa fa-external-link'></i>
          </a>

        </p>
        <p class='u-muted'>
          This data is licensed under the terms of the
          <a href='http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3'>
            Open Government License
          </a>.
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

    locationUri() {
      return this.$store.state.location.uri;
    },

    locationName() {
      if (!this.$store.state.location) {
        return null;
      }
      return this.$store.state.location.labels.en;
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
