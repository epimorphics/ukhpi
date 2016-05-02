/* jshint quotmark: double */

module.exports = function (grunt) {
  "use strict";

  // Time how long tasks take. Can  when optimizing build times
  require("time-grunt")(grunt);

  // Load grunt tasks automatically
  require("load-grunt-tasks")(grunt, {pattern: ["grunt-*", "assemble"]});

  // Configurable paths
  var config = {
    app: "app",
    dist: "dist"
  };

  // Define the configuration for all the tasks
  grunt.initConfig({

    // Project settings
    config: config,

    bowercopy: {
      options: {
        srcPrefix: "bower_components"
      },
      scripts: {
        options: {
          destPrefix: "vendor/assets"
        },
        files: {
          "javascripts/external/sizzle/": "jquery/sizzle/",
          "javascripts/jquery": "jquery/src/",
          "javascripts/d3.js": "d3/d3.js",
          "javascripts/lodash.js": "lodash/lodash.js",
          "javascripts/bootstrap/": "bootstrap-amd/lib/*.js",
          "javascripts/jquery.dataTables.js": "datatables/media/js/jquery.dataTables.js",
          "javascripts/dataTables.bootstrap.js": "datatables/media/js/dataTables.bootstrap.js",
          "stylesheets/jquery.dataTables.css": "datatables/media/css/jquery.dataTables.css",
          "stylesheets/dataTables.bootstrap.css": "datatables/media/css/dataTables.bootstrap.css",
          "images/": "datatables/media/images/*.png",
          "javascripts/bootstrap3-typeahead.js": "bootstrap3-typeahead/bootstrap3-typeahead.js",
          "javascripts/moment.js": "moment/moment.js",
          "javascripts/bootstrap-datetimepicker.js": "eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker.js",
          "stylesheets/_bootstrap-datetimepicker.scss": "eonasdan-bootstrap-datetimepicker/src/sass/_bootstrap-datetimepicker.scss"
        }
      }
    }

  });

  grunt.registerTask( "copy", [
    "bowercopy"
  ] );
};
