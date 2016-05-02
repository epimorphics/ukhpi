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
          "javascripts/d3.js": "d3/d3.js",
          "javascripts/bootstrap3-typeahead.js": "bootstrap3-typeahead/bootstrap3-typeahead.js"
          // "stylessheets/bootstrap3-typeahead.css": "bootstrap3-typeahead/bootstrap3-typeahead.css"
        }
      }
    }

  });

  grunt.registerTask( "copy", [
    "bowercopy"
  ] );
};
