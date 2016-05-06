/* Simple controller for client-side interaction in UKHPI */

modulejs.define( "controller", [
  "lib/lodash",
  "lib/jquery",
  "preferences-view",
  "routes",
  "query-results",
  "data-table-view",
  "graphs-view"
],
function(
  _,
  $,
  PreferencesView,
  Routes,
  QueryResults,
  DataTableView,
  GraphsView
) {
  "use strict";

  var Controller = function() {
    this.createComponents();
    this.bindEvents();
    this.loadResults();
  };

  _.extend( Controller.prototype, {
    createComponents: function() {
      this.components = {
        preferencesView: new PreferencesView(),
        dataTableView: new DataTableView(),
        graphsView: new GraphsView()
      };
    },

    component: function( c ) {
      return this.components[c];
    },

    bindEvents: function() {
      $("body").on( "changeAspectSelection", _.bind( this.renderCurrentQueryResults, this ) );
      $("body").on( "changePreferences", _.bind( this.loadResults, this ) );
    },

    loadResults: function() {
      $.getJSON( Routes.new_exploration, this.component( "preferencesView" ).preferences() )
       .done( _.bind( this.onUpdateData, this ) )
       .error( function( e, m, a ) {
        console.log( "API get failed: " );
        console.log( e );
        console.log( m );
        console.log( a );
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
    }

  } );

  return Controller;
} );
