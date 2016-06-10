/** Model object encapsulating a single result */

modulejs.define( "query-result", [
  "lib/lodash",
  "lib/moment"
],
function(
  _,
  moment
) {
  "use strict";

  var QueryResult = function( data ) {
    this._data = data;
    this.indexData( data );
  };

  _.extend( QueryResult.prototype, {
    value: function( aspect ) {
      var val = this._data[aspect];
      return _.isArray( val ) ? _.first( val ) : val;
    },

    valuesFor: function( slugs ) {
      return _.map( slugs, _.bind( this.valueFor, this ) );
    },

    valueFor: function( slug ) {
      return this._sData[slug];
    },

    indexData: function( data ) {
      this._sData = {};
      var sData = this._sData;

      _.each( data, function( v, k ) {
        var match = k.match( /^ukhpi:(.*)/ );
        if (match) {
          sData[match[1]] = (v && _.isArray(v)) ? _.first( v ) : v;
        }
      } );
    },

    slug: function( name ) {
      var n = name.replace( /^ukhpi:/, "" );
      var nUpper = n.replace( /[a-z]/g, "" );
      return (n.slice( 0, 1 ) + nUpper).toLocaleLowerCase();
    },

    period: function() {
      return this._data["ukhpi:refMonth"]["@value"];
    },

    duration: function() {
      return this._data["ukhpi:refPeriodDuration"][0];
    },

    /** @return A momentJS object denoting the (start of the) period as a date */
    periodDate: function() {
      if (!this._date) {
        this._date = moment( this.period(), "YYYY-MM" );
      }

      return this._date;
    }
  } );

  return QueryResult;
} );
