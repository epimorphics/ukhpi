/* Simple controller for client-side interaction in UKHPI */

define( [
  "lodash",
  "jquery",
  "preferences-view",
  "routes"
],
function(
  _,
  $,
  PreferencesView,
  Routes
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
        preferencesView: new PreferencesView()
      };
    },

    component: function( c ) {
      return this.components[c];
    },

    bindEvents: function() {

    },

    loadResults: function() {
      $.getJSON( Routes.new_exploration, this.component( "preferencesView" ).preferences() )
       .done( _.bind( this.onUpdateData, this ) )
       .error( function( e, m, a ) {
        console.log( "API get failed: " );
        console.log( e );
        console.log( m );
        console.log( a );
       })
    },

    onUpdateData: function( data ) {
      this.component( "preferencesView" ).updatePrompt( data );
    }

  } );

  return Controller;
} );
