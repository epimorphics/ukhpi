import _ from 'lodash';
import QueryResult from './query-result';

/** Data model encapsulating the results we got back from the server */
export default class QueryResults {
  constructor(data) {
    this.json = data;
  }

  selections() {
    return this.json.selections;
  }

  location() {
    return this.selections().location;
  }

  results() {
    if (!this.$results) {
      this.$results = _.map(this.json.results, result => new QueryResult(result));
    }

    return this.$results;
  }

  size() {
    return this.results().length;
  }

  /* @return A projection of the statistics in this query result according to a
   * theme, which defines a subset of statistics. Returns all theme statistics;
   * does not restrict to currently-displayed only. */
  projection(indicator, theme) {
    const projection = {};

    theme.statistics.forEach((statistic) => {
      const pred = `ukhpi:${indicator ? indicator.rootName : ''}${statistic.rootName}`;
      projection[statistic.slug] = this.series(pred);
    });

    return projection;
  }

  /* @return The data in a particular category series, as determined by the qname
   * of the data-cube predicate */
  series(pred) {
    const s = this.results().map((r) => {
      const val = r.value(pred);

      if (_.isFinite(val)) {
        return {
          x: r.periodDate().toDate(),
          y: r.value(pred),
          pred,
        };
      }

      return null;
    });

    return _.sortBy(_.compact(s), d => d.x);
  }

  /** @return The duration of the selected results, if known */
  duration() {
    if (this.results().length > 0) {
      return this.results()[0].duration();
    }

    return 0;
  }
}
