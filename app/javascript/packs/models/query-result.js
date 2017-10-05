import _ from 'lodash';
import Moment from 'moment';
import Numeral from 'numeral';

/** @return A simplified data value, suitable for display in a data table */
function toSimpleValue(value) {
  // this is the recommended way to strip away the Vue observer wrapper
  let simpleValue = JSON.parse(JSON.stringify(value));

  if (simpleValue['@value']) {
    simpleValue = simpleValue['@value'];
  }
  if (simpleValue['@id']) {
    simpleValue = simpleValue['@id'];
  }
  if (simpleValue instanceof Array && simpleValue.length === 1) {
    simpleValue = _.first(simpleValue);
  }

  return simpleValue;
}

function formatTableDatum(prop, rawValue) {
  const value = toSimpleValue(rawValue);

  if (!value || value.length === 0) {
    return 'no value';
  } else if (prop.match(/percentage/i)) {
    return Numeral(value).divide(100).format('0.00%');
  } else if (prop.match(/housePriceIndex/)) {
    return Numeral(value).format('0.00');
  } else if (prop.match(/average/)) {
    return Numeral(value).format('$0,0');
  } else if (prop.match(/volume/)) {
    return Numeral(value).format('0,0');
  } else if (prop.match(/refMonth/)) {
    return Moment(value, 'YYYY-MM').format('MMM YYYY');
  }

  return value;
}

/** Model object encapsulating a single result */
export default class QueryResult {
  constructor(data) {
    this.json = data;
  }

  value(pred) {
    return toSimpleValue(this.json[pred]);
  }

  period() {
    return this.value('ukhpi:refMonth');
  }

  /** @return A momentJS object denoting the (start of the) period as a date */
  periodDate() {
    if (!this.date) {
      this.date = Moment(this.period(), 'YYYY-MM');
    }

    return this.date;
  }

  duration() {
    return this.value('ukhpi:refPeriodDuration');
  }

  /** @return A simplified view of this data, suitable for injecting into a data table */
  asTableData() {
    const tableData = {};

    _.forEach(this.json, (value, key) => {
      tableData[key] = formatTableDatum(key, value);
    });

    return tableData;
  }
}
