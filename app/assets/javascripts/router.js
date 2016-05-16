/** Simple router to invoke the correct controller based on the current path */

modulejs.define( "router", [
  "lib/lodash",
  "explore-controller"
], function(
  _,
  ExploreController
) {
  "use strict";

  var Router = function() {
  };

  _.extend( Router.prototype, {
    /** Keep this really simple for now. We can complicate later if needed */
    invoke: function( route ) {
      if (route.pathname.match( /\/explore/ )) {
        this._controller = new ExploreController();
      }

      if (!this._controller) {
        console.log( "No controller for route: " + route );
      }
      else {
        if (this._controller.init) {
          this._controller.init();
        }
      }
    },

    controller: function() {
      return this._controller;
    }
  } );

  return Router;
} );
