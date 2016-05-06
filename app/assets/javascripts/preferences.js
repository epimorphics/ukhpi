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
    this.initialize();
  };

  _.extend( Preferences.prototype, {
    initialize: function() {
      this._prefs = {};
      var prefs = this._prefs;

      var selections = $("#preferences").serializeArray();
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
    },

    region: function() {
      return this._prefs.region;
    },

    from: function() {
      return this._prefs.from;
    },

    to: function() {
      return this._prefs.to;
    },

    /** @return The currently selected indicators, optionally limited to just a given selection */
    indicators: function( only ) {
      var ai = this._prefs.ai || [];
      if (only && only.indicators) {
        ai = _.intersection( only.indicators, ai );
      }

      return ai;
    },

    /** @return The currently selected categories, optionally limited to just a given selection */
    categories: function( only ) {
      var ac = this._prefs.ac || [];
      if (only && only.categories) {
        ac = _.intersection( only.categories, ac );
      }

      return ac;
    },

    /** @return The selected aspects, optionally limited to only certain indicators or categories */
    aspects: function( only ) {
      var pairs = cartesianProductOf( this.indicators( only ), this.categories( only ) );

      return _.map( pairs, function( pair ) {
        return pair[0] + _.upperFirst( pair[1] );
      } );
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
  };

  return Preferences;
} );
