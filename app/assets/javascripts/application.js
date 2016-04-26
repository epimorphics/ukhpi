define( [
  "lodash",
  "jquery/jquery",
  "controller",
  "bootstrap/bootstrap"
],
function(
  _,
  $,
  Controller
) {
  "use strict";

  var controller = new Controller();

  return {
    controller: controller
  };
} );
