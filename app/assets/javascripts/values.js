modulejs.define( "values", [
  "lib/lodash",
  "lib/js-logger",
  "aspects"
],
function(
  _,
  Log,
  Aspects
) {
  "use strict";
  var DECIMAL_PLACES = 2;

  var formatValue = function( aspectName, value ) {
    var aspect = Aspects[aspectName];

    if (_.isNull( value ) || _.isUndefined( value )) {
      return "not available";
    }

    switch (aspect.unitType) {
      case "percentage":
        return value + "%";
      case "pound_sterling":
        return asCurrency( parseInt( value ) );
      case "integer":
        return value.toFixed();
      case "decimal":
        return value.toFixed( DECIMAL_PLACES );
      default:
        return value;
    }
  };

  var asCurrency = function( value ) {
    try {
      var formattedValue = value.toLocaleString(  "en-GB", {
        style: "currency",
        currency: "GBP"
      } );

      // we should be able to set maximumFractionDigits to 0 above, but
      // this causes a crash in Firefox
      return formattedValue.replace( /\.00$/, "" );
    }
    catch (e) {
      Log.warn( "Failed to format value as currency: '" + value + "'");
      return "";
    }
  };

  return {
    asCurrency: asCurrency,
    formatValue: formatValue
  };
} );
