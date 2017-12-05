<template lang='html'>
  <div class='o-data-view-download'>
    <el-row>
      <el-col :span='18'>
        <p>
          You can download this data, so that you can process it further yourself.
        </p>
        <ul>
          <li>
            Download only data for <strong>{{ indicator.label }}</strong>:
            <a class='o-data-view-download__button' :href='downloadUrl("csv", true)'>
              download CSV/spreadsheet <i class='fa fa-external-link'></i>
            </a>
            <a class='o-data-view-download__button' :href='downloadUrl("json", true)'>
              download JSON <i class='fa fa-external-link'></i>
            </a>
          </li>
          <li>
            Download all statistics for <strong>{{ theme.label }}</strong>:
            <a class='o-data-view-download__button' :href='downloadUrl("csv", false)' download>
              download CSV/spreadsheet <i class='fa fa-external-link'></i>
            </a>
            <a class='o-data-view-download__button' :href='downloadUrl("json", false)' download>
              download JSON <i class='fa fa-external-link'></i>
            </a>
          </li>
        </ul>
        <p>
          You can also download
          <a href=''>all UKHPI data for the selected location and period</a>,
          or <br />
          <a :href='qonsolePath'>try the SPARQL query</a>
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
  },

  methods: {
    /**
     * Calculate the URL for downloading a particular slice of the data
     * @param  {String} mediaType     Desired media type, e.g. json
     * @param  {Boolean} onlyIndicator If true, download only the current indicator
     * @return {String}               The download URL
     */
    downloadUrl(mediaType, onlyIndicator) {
      const options = {
        format: mediaType,
        'thm[]': this.theme.slug,
        from: this.fromDate,
        to: this.toDate,
      };

      if (onlyIndicator && this.indicator) {
        options['in[]'] = this.indicator.slug;
      }

      return `${Routes.newDownloadPath(options)}`;
    },
  },
};
</script>

<style lang='scss'>
</style>
