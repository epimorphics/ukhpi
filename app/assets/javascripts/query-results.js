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

    location: function() {
      return this._data.prefsSummary.replace( /,.*/, "" );
    },

    results: function() {
      if (!this._results) {
        this._results = _.map( this._data.results, function( result ) {
          return new QueryResult( result );
        } );
      }

      return this._results;
    },

    size: function() {
      return this.results().length;
    },

    dateRange: function() {
      var min = _.minBy( this.results(), function( r) { return r.periodDate().toDate(); } );
      var max = _.maxBy( this.results(), function( r) { return r.periodDate().toDate(); } );

      return min && [min.periodDate().toDate(), max.periodDate().toDate()];
    },

    /* @return The data in a particular category series */
    series: function( indicator, category ) {
      var aspect = "ukhpi:" + indicator + category;
      var s = _.map( this.results(), function( r ) {
        var val = r.value( aspect );
        if (_.isFinite( val )) {
          return {x: r.periodDate().toDate(),
                  y: r.value( aspect ),
                  ind: indicator,
                  cat: category};
        }
        else {
          console.log( "missing value for " + aspect + " " + r.periodDate().format( "YYYY-MM" ));
          return null;
        }
      } );

      return _.sortBy( _.compact( s ), function( d ) {return d.x;} );
    },

    /** @return The duration of the selected results, if known */
    duration: function() {
      if (this.results().length > 0) {
        return this.results()[0].duration();
      }
      else {
        return 0;
      }
    }
  } );

  return QueryResults;
} );
