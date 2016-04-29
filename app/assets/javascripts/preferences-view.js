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
    this.bindEvents();
  };

  _.extend( PreferencesView.prototype, {
    preferences: function() {
      return $("#preferences").serialize();
    },

    bindEvents: function() {
      $(".js-reveal-button").on( "click", _.bind( this.onToggleRevealPreferences, this ) );
      $(".js-aspect").on( "click", function() {
        $("body").trigger( "changeAspectSelection" );
      } );
    },

    updatePrompt: function( qr ) {
      $(".js-search-prompt").text( qr.prefsSummary() );
    },

    onToggleRevealPreferences: function( e ) {
      e.preventDefault();
      $(".js-reveal-button").toggleClass( "revealing" );
      $(".js-preferences-form").toggleClass( "hidden" );
      $(".js-preferences").tab();
    }
  } );

  return PreferencesView;
} );
