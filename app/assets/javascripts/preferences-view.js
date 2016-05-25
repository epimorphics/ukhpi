/** Component for display the user preferences */

modulejs.define( "preferences-view", [
  "lib/lodash",
  "lib/jquery",
  "lib/util",
  "constants",
  "regions-table",
  "preferences"
],
function(
  _,
  $,
  Util,
  Constants,
  RegionsTable,
  Preferences
) {
  "use strict";

  var PreferencesView = function() {
    this.bindEvents();
    this.setupTypeahead();
    this.setupDateTimePickers();
    this.setPreferencesLinkURLs();
  };

  var COUNTY_TYPE =  "http://data.ordnancesurvey.co.uk/ontology/admingeo/County";
  var UNITARY_TYPE = "http://data.ordnancesurvey.co.uk/ontology/admingeo/UnitaryAuthority";
  var BOROUGH_TYPE = "http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough";
  var DISTRICT_TYPE = "http://data.ordnancesurvey.co.uk/ontology/admingeo/District";
  var GLA_TYPE = "http://data.ordnancesurvey.co.uk/ontology/admingeo/GreaterLondonAuthority";
  var LONDON_BOROUGH_TYPE = "http://data.ordnancesurvey.co.uk/ontology/admingeo/LondonBorough";
  var METRO_DISTRICT_TYPE = "http://data.ordnancesurvey.co.uk/ontology/admingeo/MetropolitanDistrict";

  var COUNTY_TYPES = [COUNTY_TYPE];
  var LOCAL_AUTH_TYPES = [BOROUGH_TYPE, DISTRICT_TYPE, GLA_TYPE,
                          LONDON_BOROUGH_TYPE, METRO_DISTRICT_TYPE, UNITARY_TYPE];

  _.extend( PreferencesView.prototype, {
    preferences: function() {
      return $("#preferences-js").serialize();
    },

    bindEvents: function() {
      $(".js-reveal-button").on( "click", _.bind( this.onToggleRevealPreferences, this ) );
      $(".js-aspect").on( "click", function() {
        $("body").trigger( Constants.EVENT_ASPECTS_CHANGE );
      } );
      $(".js-location-type").on( "click", _.bind( this.onChangeLocationType, this ) );
      $(".c-location-search input[type=radio]").on( "click", _.bind( this.onSelectLocationOption, this ) );
      $("body")
        .on( Constants.EVENT_SELECTED_MAP, _.bind( function() {
          this.onLocationSelected.apply( this, arguments );
          // this.onPreferencesChange.apply( this, arguments );
        }, this ) )
        .on( Constants.EVENT_PREFERENCES_CHANGE, _.bind( this.onPreferencesChange, this ) )
        .on( Constants.EVENT_ASPECTS_CHANGE, _.bind( this.onPreferencesChange, this ) );
    },

    updatePrompt: function( qr ) {
      $(".js-search-prompt span").text( qr.prefsSummary() );
    },

    onToggleRevealPreferences: function( e ) {
      e.preventDefault();
      Util.JQuery.spinStart();

      _.defer( function() {
        $(".js-reveal-button").toggleClass( "revealing" );
        $(".js-preferences-form").toggleClass( "hidden" );
        $(".js-preferences").tab();

        if ($(".js-preferences-form").is( ":not(.hidden)" )) {
          $("body").trigger( Constants.EVENT_PREFS_REVEALED );
        }

        Util.JQuery.spinStop();
      });
    },

    setupTypeahead: function() {
      var countyNames = [];
      var laNames = [];

      _.each( RegionsTable.names, function( name ) {
        if (name.lang === "en") {
          var uri = name.value;
          var type = RegionsTable.locations[uri].type;

          if (_.includes( COUNTY_TYPES, type )) {
            countyNames.push( {name: name.label, uri: uri} );
          }
          else if (_.includes( LOCAL_AUTH_TYPES, type )) {
            laNames.push( {name: name.label, uri: uri} );
          }
        }
      });

      $( ".county .js-location" ).typeahead( {
        source: countyNames,
        afterSelect: _.bind( this.onAutocompleteSelect, this )
      } );
      $( ".local-authority .js-location" ).typeahead( {
        source: laNames,
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
      $("body")
        .trigger( Constants.EVENT_PREFERENCES_CHANGE )
        .trigger( Constants.EVENT_LOCATION_SELECTED, uri );
    },

    setupDateTimePickers: function() {
      _.each( ["#fromdatepicker, #todatepicker"], function( sel ) {
        $(sel).datetimepicker( {
          viewMode: "years",
          format: "YYYY-MM"
        }).on( "dp.change", function() {
          $("body").trigger( Constants.EVENT_PREFERENCES_CHANGE );
        });
      } );
    },

    onChangeLocationType: function( e ) {
      var target = $(e.currentTarget).val();
      $("body").trigger( Constants.EVENT_LOCATION_TYPE_CHANGE, {locationType: target} );
    },

    onSelectLocationOption: function( e ) {
      var elem = $(e.currentTarget);
      this.resetSelections( true );
      elem.attr( "selected", true );
      this.selectLocation( elem.val() );
    },

    onLocationSelected: function( e, uri ) {
      var elem = $(".js-location-uri");
      if (elem.val() !== uri) {
        $(".js-location-choice:checked").prop( "checked", false );

        var inputElem = $(".js-location-choice[value='" + uri + "']");
        if (inputElem.length > 0) {
          inputElem.click();
        }
        else {
          var regionName = _.find( RegionsTable.names, {value: uri} ).label;
          $(".js-location:visible").val( regionName );
          this.selectLocation( uri );
        }
      }
    },

    onPreferencesChange: function() {
      this.setPreferencesLinkURLs();
    },

    setPreferencesLinkURLs: function() {
      var prefs = new Preferences();
      var params = "?" + prefs.asURLParameters();

      $(".js-preferences-url").each( function( i, elem ) {
        var link = $(elem);
        var url = link.attr( "href" ).replace( /\?.*$/, "" );
        link.attr( "href", url + params );
      } );
    }
  } );

  return PreferencesView;
} );
