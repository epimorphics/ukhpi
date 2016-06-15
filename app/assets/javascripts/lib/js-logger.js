/* Client-side invocation of the JsLogger API */

modulejs.define( "lib/js-logger", [
  "lib/lodash",
  "lib/jquery",
  "routes"
],
function(
  _,
  $,
  Routes
) {
  "use strict";

  var DEFAULT_PATH = "logger/rails_client_logger/log";

  var serviceURL = function() {
    return Routes.public_path + DEFAULT_PATH;
  };

  var csrfToken = function() {
    return $("meta[name='csrf-token']").attr( "content" );
  };

  var log = function( level, message ) {
    return $.ajax( {
      type: "post",
      beforeSend: function( xhr ) {
        xhr.setRequestHeader( "X-CSRF-Token", csrfToken() );
      },
      data: {
        level: level,
        message: "[ClientLog::" + level "] " + message
      },
      url: serviceURL()
    } );
  };

  return {
    debug: _.partial( log, "debug" ),
    info: _.partial( log, "info" ),
    warn: _.partial( log, "warn" ),
    error: _.partial( log, "error" ),
    fatal: _.partial( log, "fatal" )
  };
} );
