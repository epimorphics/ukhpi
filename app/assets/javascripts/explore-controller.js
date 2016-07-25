/* Simple controller for client-side interaction in UKHPI */

modulejs.define( "explore-controller", [
  "lib/lodash",
  "lib/jquery",
  "lib/js-logger",
  "constants",
  "preferences-view",
  "routes",
  "query-results",
  "data-table-view",
  "graphs-view",
  "map-view",
  "lib/ajax-monitor"
],
function(
  _,
  $,
  Log,
  Constants,
  PreferencesView,
  Routes,
  QueryResults,
  DataTableView,
  GraphsView,
  MapView
) {
  "use strict";

  var Controller = function() {
    this.createComponents();
    this.bindEvents();
    this.onPreferencesChange();
    this.setDefaultLocation();
  };

  _.extend( Controller.prototype, {
    init: function() {
    },

    createComponents: function() {
      this.components = {
        preferencesView: new PreferencesView(),
        dataTableView: new DataTableView(),
        graphsView: new GraphsView(),
        mapView: new MapView()
      };
    },

    component: function( c ) {
      return this.components[c];
    },

    bindEvents: function() {
      $("body").on( Constants.EVENT_ASPECTS_CHANGE, _.bind( this.renderCurrentQueryResults, this ) );
      $("body").on( Constants.EVENT_PREFERENCES_CHANGE, _.bind( this.onPreferencesChange, this ) );
    },

    onPreferencesChange: function() {
      var prefs = this.component( "preferencesView" ).preferences();
      this.loadResults( prefs );
      this.explainQuery( prefs );
    },

    loadResults: function( prefs ) {
      $.getJSON( Routes.newExploration, prefs )
       .done( _.bind( this.onUpdateData, this ) )
       .error( function( e, m ) {
        Log.warn( "Failed to get exploration results: " + m + ", " + e );
       });
    },

    onUpdateData: function( data ) {
      this._qr = new QueryResults( data );
      this.component( "preferencesView" ).updatePrompt( this._qr );
      this.renderQueryResults( this._qr );
    },

    renderCurrentQueryResults: function() {
      this.renderQueryResults( this._qr );
    },

    renderQueryResults: function( qr ) {
      this.component( "dataTableView" ).showQueryResults( qr );
      this.component( "graphsView" ).showQueryResults( qr );
    },

    setDefaultLocation: function() {
      this.components.mapView.setDefaultLocation( Constants.DEFAULT_LOCATION );
    },

    explainQuery: function( prefs ) {
      var explainPrefs = prefs + "&explain=true";
      $.getJSON( Routes.newExploration, explainPrefs )
       .done( _.bind( this.onExplanation, this ) )
       .error( function( e ) {
        Log.warn( "Failed to explain query via DsAPI: " + e );
      } );
    },

    onExplanation: function( data ) {
      $("body").trigger( Constants.EVENT_EXPLANATION_CHANGE, data );
    }

  } );

  return Controller;
} );
