/** Data model encapsulating the results we got back from the server */

modulejs.define( "query-results", [
  "lib/lodash",
  "query-result"
], function(
  _,
  QueryResult
) {
  "use strict";

  var QueryResults = function( data ) {
    this._data = data;
  };

  _.extend( QueryResults.prototype, {
    prefsSummary: function() {
      return this._data.prefsSummary;
    },

    results: function() {
      if (!this._results) {
        this._results = _.map( this._data.results, function( result ) {
          return new QueryResult( result );
        } );
      }

      return this._results;
    },

    dateRange: function() {
      var min = _.minBy( this.results(), function( r) { return r.periodDate().toDate(); } );
      var max = _.maxBy( this.results(), function( r) { return r.periodDate().toDate(); } );

      return [min.periodDate()
                 .toDate(),
              max.periodDate()
                 .toDate()];
    },

    /* @return The data in a particular category series */
    series: function( indicator, category ) {
      var aspect = "ukhpi:" + indicator + category;
      var s = _.map( this.results(), function( r ) {
        return {x: r.periodDate().toDate(),
                y: r.value( aspect ),
                ind: indicator,
                cat: category};
      } );

      return _.sortBy( s, function( d ) {return d.x;} );
    }
  } );

  return QueryResults;
} );
