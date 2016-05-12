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
// = require_tree .

modulejs.define( "application", [
  "controller"
],
function(
  Controller
) {
  "use strict";

  /** Issue https://github.com/epimorphics/ukhpi/issues/2
   * Something is adding functions to String.prototype, but I'm
   * not sure what. In any case, this causes a for..in loop in
   * jQuery dataTables to explode with a 'doesn't respond to charAt
   * message. The only workaround I have at the moment, unsatisfactorily,
   * is to remove the additional functions from the String prototype
   */
  delete String.prototype.startsWith;
  delete String.prototype.repeat;

  var controller = new Controller();

  return {
    controller: controller
  };
} );

$( function() {
  modulejs.require( "application" );
} );
