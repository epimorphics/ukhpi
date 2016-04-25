/* Simple controller for client-side interaction in UKHPI */

define( [
  "lodash",
  "jquery",
  "preferences-view"
],
function(
  _,
  $,
  PreferencesView
) {
  "use strict";

  var Controller = function() {
    this.createComponents();
    this.bindEvents();
  };

  _.extend( Controller.prototype, {
    createComponents: function() {
      this.components = {
        preferencesView: new PreferencesView()
      };
    },

    bindEvents: function() {

    }

  } );

  return Controller;
} );
