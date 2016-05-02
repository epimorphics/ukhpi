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
      return _.map( this._data.results, function( result ) {
        return new QueryResult( result );
      } );
    }
  } );

  return QueryResults;
} );
