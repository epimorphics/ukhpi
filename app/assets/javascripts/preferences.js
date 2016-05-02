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

    aspects: function() {
      var inds = this._prefs.ai || [];
      var cats = this._prefs.ac || [];
      var pairs = cartesianProductOf( inds, cats );

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
