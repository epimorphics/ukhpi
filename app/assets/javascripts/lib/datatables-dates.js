/* Date formatting plugin for DataTables */

modulejs.define( "lib/datatables-dates", [
  "lib/jquery",
  "lib/moment"
],
function(
  jQuery,
  moment
) {
  "use strict";

  jQuery.fn.dataTable.render.moment = function ( from, to, locale ) {
      // Argument shifting
      if ( arguments.length === 1 ) {
          locale = "en";
          to = from;
          from = "YYYY-MM-DD";
      }
      else if ( arguments.length === 2 ) {
          locale = "en";
      }

      return function ( d, type ) {
          var m = moment( d, from, locale, true );

          // Order and type get a number value from Moment, everything else
          // sees the rendered value
          return m.format( type === "sort" || type === "type" ? "x" : to );
      };
  };

  return {};
} );
