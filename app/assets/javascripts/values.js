modulejs.define( "values", [
  "lib/lodash",
  "aspects"
],
function(
  _,
  Aspects
) {
  "use strict";

  var formatValue = function( aspectName, value ) {
    var aspect = Aspects[aspectName];
    switch (aspect.unitType) {
      case "percentage":
        return value + "%";
      case "pound_sterling":
        return "£" + value;
      default:
        return _.isFinite( value ) ? value.toFixed( 2 ) : value;
    }
  };

  return {
    formatValue: formatValue
  };
} );
