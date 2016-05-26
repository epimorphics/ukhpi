/** Model object to encapsulate the current user preferences */

modulejs.define( "preferences", [
  "lib/lodash",
  "lib/jquery"
], function(
  _,
  $
) {
  "use strict";

  var Preferences = function() {
  };

  _.extend( Preferences.prototype, {
    loadPrefs: function() {
      var prefs = {};

      var selections = $("#preferences-js").serializeArray();
      _.each( selections, function( selection ) {
        var name = selection.name;

        if (name.match( /\[\]/ )) {
          var simpleName = name.replace( "[]", "" );

          if (!prefs[simpleName]) {
            prefs[simpleName] = [];
          }
          prefs[simpleName].push( selection.value );
        }
        else {
          prefs[name] = selection.value;
        }
      } );

      return prefs;
    },

    region: function() {
      return this.loadPrefs().region;
    },

    from: function() {
      return this.loadPrefs().from;
    },

    to: function() {
      return this.loadPrefs().to;
    },

    /** @return The currently selected indicators, optionally limited to just a given selection */
    indicators: function( only ) {
      var ai = this.loadPrefs().ai || [];
      if (only && only.indicators) {
        ai = _.intersection( only.indicators, ai );
      }

      return ai;
    },

    /** @return The currently selected categories, optionally limited to just a given selection */
    categories: function( only ) {
      var ac = this.loadPrefs().ac || [];
      if (only && only.categories) {
        ac = _.intersection( only.categories, ac );
      }

      return ac;
    },

    /** @return The currently selected common stats */
    commonStats: function( only ) {
      var cs = this.loadPrefs().cs || [];
      if (only && only.common) {
        cs = _.intersection( only.common, cs );
      }

      return cs;
    },

    /** @return The preferences for base graph types to display */
    visibleGraphTypes: function() {
      return this.indicators().concat( this.commonStats() );
    },

    /** @return The selected aspects, optionally limited to only certain indicators or categories */
    aspects: function( only ) {
      var pairs = cartesianProductOf( this.indicators( only ), this.categories( only ) );

      var compoundAspects = _.map( pairs, function( pair ) {
        return pair[0] + _.upperFirst( pair[1] );
      } );

      return compoundAspects.concat( this.commonStats( only ) );
    },

    asURLParameters: function() {
      var prefs = this.loadPrefs();
      var pairs = [];

      _.each( prefs, function( v, k ) {
        if (_.isArray( v )) {
          _.each( v, function( va ) {
            pairs.push( [k.toString() + "[]", encodeURIComponent( va )].join( "=" ) );
          } );
        }
        else {
          pairs.push( [k.toString(), encodeURIComponent( v )].join( "=" ) );
        }
      } );

      return pairs.join( "&" );
    }
  } );

  function cartesianProductOf() {
    return _.reduce(arguments, function(a, b) {
      return _.flatten(_.map(a, function(x) {
        return _.map(b, function(y) {
          return x.concat([y]);
        });
      }));
    }, [ [] ]);
  }

  return Preferences;
} );
