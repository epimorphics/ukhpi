/** Component for display the user preferences */

modulejs.define( "preferences-view", [
  "lib/lodash",
  "lib/jquery",
  "regions-table"
],
function(
  _,
  $,
  RegionsTable
) {
  "use strict";

  var PreferencesView = function() {
    this.bindEvents();
    this.setupTypeahead();
    this.setupDateTimePickers();
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
      $(".js-location-type").on( "click", _.bind( this.onChangeLocationType, this ) );
      $(".c-location-search input[type=radio]").on( "click", _.bind( this.onSelectLocationOption, this ) );
    },

    updatePrompt: function( qr ) {
      $(".js-search-prompt").text( qr.prefsSummary() );
    },

    onToggleRevealPreferences: function( e ) {
      console.log("onToggleRevealPreferences");
      e.preventDefault();
      $(".js-reveal-button").toggleClass( "revealing" );
      $(".js-preferences-form").toggleClass( "hidden" );
      $(".js-preferences").tab();

      if ($(".js-preferences-form").is( ":not(.hidden)" )) {
        $("body").trigger( "ukhpi.prefs.revealed" );
      }
    },

    setupTypeahead: function() {
      console.log( "setupTypeahead " + RegionsTable.names.length);
      var names = [];
      _.each(
        RegionsTable.names,
        function( name ) {
          if (name.lang === "en" && name.label && name.label.length > 0) {
            names.push( {uri: name.value, name: name.label} );
          }
        });

      $( ".js-location" ).typeahead( {
        source: names,
        afterSelect: _.bind( this.onAutocompleteSelect, this )
      } );
    },

    /** Reset all current location selections */
    resetSelections: function( clearText ) {
      $(".c-location-search input[type=radio]").attr( "selected", null );
      if (clearText) {
        $(".c-location-search input[type=text]").val( "" );
      }
    },

    onAutocompleteSelect: function( value ) {
      this.selectLocation( value.uri );
    },

    selectLocation: function( uri ) {
      $(".js-location-uri").val( uri );
      $("body").trigger( "changePreferences" );
    },

    setupDateTimePickers: function() {
      _.each( ["#fromdatepicker, #todatepicker"], function( sel ) {
        $(sel).datetimepicker( {
          viewMode: "years",
          format: "YYYY-MM"
        }).on( "dp.change", function() {
          $("body").trigger( "changePreferences" );
        });
      } );
    },

    onChangeLocationType: function( e ) {
      var target = $(e.currentTarget).val();
      $("body").trigger( "ukhpi.location-type.change", {locationType: target} );
    },

    onSelectLocationOption: function( e ) {
      var elem = $(e.currentTarget);
      this.resetSelections( true );
      elem.attr( "selected", true );
      this.selectLocation( elem.val() );
    }
  } );

  return PreferencesView;
} );
