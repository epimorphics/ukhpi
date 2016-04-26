/** Component for display the user preferences */

define( [
  "lodash",
  "jquery"
],
function(
  _,
  $
) {
  "use strict";

  var PreferencesView = function() {
    console.log("PreferencesView initializing..." );
    this.initPreferencesForm();
  };

  _.extend( PreferencesView.prototype, {
    preferences: function() {
      return $("#preferences").serialize();
    },

    initPreferencesForm: function() {
      $("form .js-hidden").addClass( "hidden" );
      $("form .js-hidden input").attr( "type", "hidden" );
    },

    updatePrompt: function( data ) {
      $(".js-search-prompt").text( data.prefsSummary );
    }
  } );

  return PreferencesView;
} );
