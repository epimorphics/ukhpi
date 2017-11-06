<template lang='html'>
  <div class='o-data-view-download'>
    <el-row>
      <el-col :span='18'>
        <p>
          You can download this data, so that you can process it further yourself.
        </p>
        <ul>
          <li>
            Only data for <strong>{{ indicatorName }}</strong>:
            <a class='o-data-view-download__button' :href='downloadUrl("csv", true)'>
              download CSV/spreadsheet <i class='fa fa-external-link'></i>
            </a>
            <a class='o-data-view-download__button' :href='downloadUrl("json", true)'>
              download JSON <i class='fa fa-external-link'></i>
            </a>
          </li>
          <li>
            All statistics for <strong>{{ themeName }}</strong>:
            <a class='o-data-view-download__button' :href='downloadUrl("csv", false)'>
              download CSV/spreadsheet <i class='fa fa-external-link'></i>
            </a>
            <a class='o-data-view-download__button' :href='downloadUrl("json", false)'>
              download JSON <i class='fa fa-external-link'></i>
            </a>
          </li>
        </ul>
        <p>
          You can also download
          <a href=''>all UKHPI data for the selected location and period</a>,
          or <br />
          <a href=''>try the SPARQL query</a>
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
export default {
  props: {
    indicator: {
      required: false,
      type: Object,
    },
    indicatorName: {
      required: false,
      type: String,
    },
    theme: {
      required: true,
      type: Object,
    },
    themeName: {
      required: true,
      type: String,
    },
  },

  methods: {
    downloadUrl(mediaType, onlyIndicator) {
      return 'foo';
    },
  },
};
</script>

<style lang='scss'>
</style>
