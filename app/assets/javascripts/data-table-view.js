/** Component for showing the queried index data as a table */

define( [
  "lodash",
  "jquery",
  "preferences",
  "dataTables.bootstrap"
], function(
  _,
  $,
  Preferences
) {
  "use strict";

  var DataTableView = function() {
  };

  _.extend( DataTableView.prototype, {
    showQueryResults: function( qr ) {
      var aspects = this.preferences().aspects();
      var data = this.formulateData( qr, aspects );

      $(".c-results").removeClass( "js-hidden" );
      $("#results-table").DataTable( {
        data: data,
        destroy: true,  // todo there are more efficient ways than this
        columns: [
          {title: "Date"},
          {title: "Measure"},
          {title: "Value", type: "num"}
        ]
      } );
    },

    preferences: function() {
      return new Preferences();
    },

    formulateData: function( qr, aspects ) {
      var rowSets = _.map( qr.results(), function( result ) {
        var values = result.valuesFor( aspects );
        var zValues = _.zip( aspects, values );

        return _.map( zValues, function( zv ) {
          return [
            result.period(),
            zv[0],
            zv[1] || null
          ];
        } );
      } );

      return _.flatten( rowSets );
    }

  } );

  return DataTableView;
} );
