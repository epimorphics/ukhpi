// = require jquery
// = require lodash
// = require modulejs
// = require bootstrap
// = require dataTables/jquery.dataTables
// = require dataTables/bootstrap/3/jquery.dataTables.bootstrap
// = require moment
// = require bootstrap-datetimepicker
// = require bootstrap3-typeahead
// = require_tree .

modulejs.define( "application", [
  "controller"
],
function(
  Controller
) {
  "use strict";

  var controller = new Controller();

  return {
    controller: controller
  };
} );

$( function() {
  modulejs.require( "application" );
} );
