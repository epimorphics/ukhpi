import _ from 'lodash';

const DECIMAL_PLACES = 2;

export function asCurrency(value) {
  try {
    const formattedValue = value.toLocaleString('en-GB', {
      style: 'currency',
      currency: 'GBP',
    });

    // we should be able to set maximumFractionDigits to 0 above, but
    // this causes a crash in Firefox
    return formattedValue.replace(/\.00$/, '');
  } catch (e) {
    // TODO Log.warn(`Failed to format value as currency: '${value}'`);
    return '';
  }
}

export function formatValue(aspect, value) {
  if (_.isNull(value) || _.isUndefined(value)) {
    return 'not available';
  }

  switch (aspect.unitType) {
    case 'percentage':
      return `${value}%`;
    case 'pound_sterling':
      return asCurrency(parseInt(value, 10));
    case 'integer':
      return value.toFixed();
    case 'decimal':
      return value.toFixed(DECIMAL_PLACES);
    default:
      return value;
  }
}
