// = require jquery
// = require lodash
// = require modulejs
// = require bootstrap
// = require dataTables/jquery.dataTables
// = require dataTables/bootstrap/3/jquery.dataTables.bootstrap
// = require moment
// = require bootstrap-datetimepicker
// = require bootstrap3-typeahead
// = require d3
// = require leaflet
// = require_tree .

modulejs.define( "application", [
  "router"
],
function(
  Router
) {
  "use strict";

  var router = new Router();
  router.invoke( window.location );

  return {
    router: router
  };
} );

/* global $ */
$( function() {
  "use strict";
  modulejs.require( "application" );
} );
