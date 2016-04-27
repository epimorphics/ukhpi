/** Component for display the user preferences */

define( [
  "lodash",
  "jquery/jquery"
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
    },

    updatePrompt: function( data ) {
      $(".js-search-prompt").text( data.prefsSummary );
    },

    onToggleRevealPreferences: function( e ) {
      e.preventDefault();
      $(".js-reveal-button").toggleClass( "revealing" );
      $(".js-preferences-form").toggleClass( "js-hidden" );
      $(".js-preferences").tab();
    }
  } );

  return PreferencesView;
} );
