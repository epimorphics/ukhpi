/** Data model encapsulating the results we got back from the server */

import _ from 'lodash';
import QueryResult from './query-result';

export default class QueryResults {
  constructor(data) {
    this.json = data;
  }

  prefsSummary() {
    return this.json.prefsSummary;
  }

  location() {
    return this.json.prefsSummary.replace(/,.*/, '');
  }

  results() {
    if (!this.results) {
      this.results = _.map(this.json.results, result => new QueryResult(result));
    }

    return this.results;
  }

  size() {
    return this.results().length;
  }

  dateRange() {
    const min = _.minBy(this.results(), r => r.periodDate().toDate());
    const max = _.maxBy(this.results(), r => r.periodDate().toDate());

    return min && [min.periodDate().toDate(), max.periodDate().toDate()];
  }

  /* @return The data in a particular category series */
  series(indicator, category) {
    const aspect = `ukhpi:${indicator}${category}`;
    const s = _.map(this.results(), (r) => {
      const val = r.value(aspect);

      if (_.isFinite(val)) {
        return {
          x: r.periodDate().toDate(),
          y: r.value(aspect),
          ind: indicator,
          cat: category,
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
