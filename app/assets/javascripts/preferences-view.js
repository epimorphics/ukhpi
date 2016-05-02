/** Component for display the user preferences */

define( [
  "lodash",
  "jquery",
  "regions-table",
  "bootstrap3-typeahead"
],
function(
  _,
  $,
  RegionsTable
) {
  "use strict";

  var PreferencesView = function() {
    console.log("PreferencesView initializing..." );
    this.bindEvents();
    this.setupTypeahead();
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
    },

    setupTypeahead: function() {
      var names = [];
      _.each(
        RegionsTable.names,
        function( name ) {
          if (name.lang === "en" && name.label && name.label.length > 0) {
            names.push( {id: name.value, name: name.label} );
          }
        });

      $( ".js-typeahead" ).typeahead( {
        source: names,
        afterSelect: _.bind( this.onAutocompleteSelect, this )
      } );
    },

    onAutocompleteSelect: function( value ) {
      $("body").trigger( "changePreferences" );
    }
  } );

  return PreferencesView;
} );
