import _ from 'lodash';
import Moment from 'moment';

/** Model object encapsulating a single result */
export default class QueryResult {
  constructor(data) {
    this.json = data;
    this.indexData(data);
  }

  value(aspect) {
    const val = this.json[aspect];
    return _.isArray(val) ? _.first(val) : val;
  }

  valuesFor(slugs) {
    return _.map(slugs, _.bind(this.valueFor, this));
  }

  valueFor(slug) {
    return this.sData[slug];
  }

  indexData(data) {
    this.sData = {};

    data.each((v, k) => {
      const match = k.match(/^ukhpi:(.*)/);
      if (match) {
        this.sData[match[1]] = (v && _.isArray(v)) ? _.first(v) : v;
      }
    });
  }

  slug = (name) => {
    const n = name.replace(/^ukhpi:/, '');
    const nUpper = n.replace(/[a-z]/g, '');
    return (n.slice(0, 1) + nUpper).toLocaleLowerCase();
  }

  period() {
    return this.json['ukhpi:refMonth']['@value'];
  }

  duration() {
    return this.json['ukhpi:refPeriodDuration'][0];
  }

  /** @return A momentJS object denoting the (start of the) period as a date */
  periodDate() {
    if (!this.date) {
      this.date = Moment(this.period(), 'YYYY-MM');
    }

    return this.date;
  }
}
