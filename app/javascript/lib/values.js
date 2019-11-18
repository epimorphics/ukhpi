import _ from 'lodash'
import Numeral from 'numeral'

export function asCurrency (value) {
  return Numeral(value).format('$0,0')
}

export function formatValue (indicator, value) {
  if (_.isNull(value) || _.isUndefined(value)) {
    return 'not available'
  }

  if (indicator.match(/index/i)) {
    return Numeral(value).format('0.0')
  } else if (indicator.match(/price/i)) {
    return Numeral(value).format('$0,0') // asCurrency(parseInt(value, 10));
  } else if (indicator.match(/percent/i)) {
    return Numeral(value / 100.0).format('%0.0')
  } else if (indicator.match(/volume/)) {
    return value.toFixed()
  }

  return value
}
