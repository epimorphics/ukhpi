<template>
  <div class="o-data-view-download">
    <el-row>
      <el-col :span="18">
        <p v-html="sanitised($t('js.download.prompt', { qonsolePath: qonsolePath }))" /><!-- eslint-disable-line vue/no-v-html -->

        <ul>
          <li>
            <!-- eslint-disable vue/no-v-html-->
            <span
              v-html="sanitised($t('js.download.selected', { themeName: themeName, indicatorName: indicatorName, locationName: locationName }))"
            />
            <!-- eslint-enable vue/no-v-html -->
            <br>
            <a
              class="o-data-view-download__button"
              :href="downloadUrl('csv', true, true)"
            >
              {{ $t('js.download.csv_prompt') }} <i class="fa fa-external-link" />
            </a>
            <a
              class="o-data-view-download__button"
              :href="downloadUrl('json', true, true)"
            >
              {{ $t('js.download.json_prompt') }} <i class="fa fa-external-link" />
            </a>
          </li>
          <li>
            <span v-html="sanitised($t('js.download.theme', { themeName: themeName, locationName: locationName }))" /><!-- eslint-disable-line vue/no-v-html -->
            <br>
            <a
              class="o-data-view-download__button"
              :href="downloadUrl('csv', true, false)"
              download
            >
              {{ $t('js.download.csv_prompt') }} <i class="fa fa-external-link" />
            </a>
            <a
              class="o-data-view-download__button"
              :href="downloadUrl('json', true, false)"
              download
            >
              {{ $t('js.download.json_prompt') }} <i class="fa fa-external-link" />
            </a>
          </li>
        </ul>
        <p>
          <span v-html="sanitised($t('js.download.all', { locationName: locationName }))" /><!-- eslint-disable-line vue/no-v-html -->
          <br>
          <a
            class="o-data-view-download__button"
            :href="downloadUrl('csv', false, false)"
            download
          >
            {{ $t('js.download.csv_prompt') }} <i class="fa fa-external-link" />
          </a>
          <a
            class="o-data-view-download__button"
            :href="downloadUrl('json', false, false)"
            download
          >
            {{ $t('js.download.json_prompt') }} <i class="fa fa-external-link" />
          </a>
        </p>
        <!-- eslint-disable vue/no-v-html-->
        <p
          class="u-muted"
          v-html="sanitised( $t('js.download.license') )"
        />
      <!-- eslint-enable vue/no-v-html-->
      </el-col>
    </el-row>
  </div>
</template>

<script>
import DOMPurify from 'dompurify';
import { newDownloadPath } from '../lib/routes.js.erb';

export default {
  props: {
    indicator: {
      required: false,
      type: Object,
      default: null,
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
    qonsolePath () {
      // If the environment is development, use the local qonsole path
      // e.g. http://localhost:3000/qonsole?query=_localstore
      // This is to ensure that the qonsole path is always the same as the current path, but with the last two segments replaced with 'qonsole'
      if (window?.ukhpi?.environment === 'development') {
        return `${window.location.protocol}//${window.location.hostname}:3000/qonsole?query=_localstore`;
      }
      // Otherwise, use the current path with the last two segments replaced with 'qonsole'
      // e.g. http://localhost:3002/foo/bar/qonsole?query=_localstore
      return `${window.location.pathname.replace(/\/[^/]*\/[^/]*$/, '/qonsole')}?query=_localstore`;
    },

    fromDate () {
      return this.$store.state.fromDate;
    },

    toDate () {
      return this.$store.state.toDate;
    },

    locationUri () {
      const { location } = this.$store.state;
      return location ? location.uri : '';
    },

    locationName () {
      const { location } = this.$store.state;
      return location ? location.labels[this.$locale] : '';
    },

    themeName () {
      return this.theme ? this.theme.label.toLocaleLowerCase() : '';
    },

    indicatorName () {
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
    downloadUrl (mediaType, withTheme, withIndicator) {
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

      return `${newDownloadPath(options)}`;
    },

    /**
     * Sanitise HTML content for safe rendering
     * @param {String} html
     * @return {String} Sanitised HTML
     */
    sanitised (html) {
      return DOMPurify.sanitize(html);
    },
  },
};
</script>

<style lang='scss'></style>
