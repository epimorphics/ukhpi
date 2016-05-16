/** Component for showing the queried index data as a table */

modulejs.define( "data-table-view", [
  "lib/lodash",
  "lib/jquery",
  "preferences",
  "aspects"
], function(
  _,
  $,
  Preferences,
  Aspects
) {
  "use strict";

  var DataTableView = function() {
  };

  _.extend( DataTableView.prototype, {
    showQueryResults: function( qr ) {
      var aspects = this.preferences().aspects();
      var data = this.formulateData( qr, aspects );

      googleAnalyticsDataTablesWorkaround();

      $(".c-results").removeClass( "js-hidden" );
      $("#results-table").DataTable( {
        data: data,
        destroy: true,  // todo there are more efficient ways than this
        columns: [
          {title: "Date"},
          {title: "Measure"},
          {title: "Value", type: "num-fmt", className: "text-right"}
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
            zv[1] ? formatValue( zv[0], zv[1] ) : null
          ];
        } );
      } );

      return _.flatten( rowSets );
    }

  } );

  var formatValue = function( aspectName, value ) {
    var aspect = Aspects[aspectName];
    switch (aspect.unitType) {
      case "percentage":
        return value + "%";
      case "pound_sterling":
        return "£" + value;
      default:
        return value;
    }
  };

  /** This bug is caused by GA side-effecting String.prototype */
  var googleAnalyticsDataTablesWorkaround = function() {
    /** Issue https://github.com/epimorphics/ukhpi/issues/2
     * Something is adding functions to String.prototype, but I'm
     * not sure what. In any case, this causes a for..in loop in
     * jQuery dataTables to explode with a 'doesn't respond to charAt
     * message. The only workaround I have at the moment, unsatisfactorily,
     * is to remove the additional functions from the String prototype
     */
    delete String.prototype.startsWith;
    delete String.prototype.repeat;
  };

  return DataTableView;
} );
