/** Model object to encapsulate the current user preferences */

define( [
  "lodash",
  "jquery"
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
      return this._prefs.aspect || [];
    }
  } );

  return Preferences;
} );
