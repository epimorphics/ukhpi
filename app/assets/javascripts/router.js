/** Simple router to invoke the correct controller based on the current path */

modulejs.define( "router", [
  "lib/lodash",
  "lib/js-logger",
  "explore-controller",
  "landing-controller"
], function(
  _,
  Log,
  ExploreController,
  LandingController
) {
  "use strict";

  var Router = function() {
  };

  _.extend( Router.prototype, {
    /** Keep this really simple for now. We can complicate later if needed */
    invoke: function( route ) {
      this._controller = resolveRoute( route.pathname );

      if (this._controller) {
        this._controller.init();
      }
    },

    controller: function() {
      return this._controller;
    }
  } );

  /** Look-up the controller by route */
  var resolveRoute = function( path )  {
    if (path.match( /\/explore/ )) {
      return new ExploreController();
    }
    else if (path.match( /(ukhpi\/?$)\(^\/?$)/ )) {
      return new LandingController();
    }
    else {
      Log.warn( "No controller for route: " + path );
      return null;
    }
  };

  return Router;
} );
