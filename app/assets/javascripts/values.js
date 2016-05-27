modulejs.define( "values", [
  "lib/lodash",
  "aspects"
],
function(
  _,
  Aspects
) {
  "use strict";
  var DECIMAL_PLACES = 2;

  var formatValue = function( aspectName, value ) {
    var aspect = Aspects[aspectName];
    switch (aspect.unitType) {
      case "percentage":
        return value + "%";
      case "pound_sterling":
        return "£" + value;
      case "integer":
        return value.toFixed()
      case "decimal":
        return value.toFixed( DECIMAL_PLACES )
      default:
        return value;
    }
  };

  return {
    formatValue: formatValue
  };
} );
