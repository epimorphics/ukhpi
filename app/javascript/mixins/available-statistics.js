/** Common code between data-view and data-view-graph-zoomed */
export default {
  computed: {
    availableStatistics() {
      const stats = this.theme.statistics;
      return stats ? stats.filter(this.statisticIsAvailable) : [];
    },

    isVolumeIndicator() {
      return this.indicator.isVolume;
    },
  },

  methods: {
    /** A statistic is available if it's not the volume indicator, or it is and a given
     * statistic does have a sales volume (which not all do).
     * @return True if the statistic should be available for this indicator
     */
    statisticIsAvailable(stat) {
      return !this.isVolumeIndicator || stat.hasVolume;
    },
  },
};
