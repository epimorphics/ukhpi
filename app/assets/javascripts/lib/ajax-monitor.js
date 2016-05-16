/** Give the user feedback when there's Ajax activity */

modulejs.define( "lib/ajax-monitor", [
  "lib/jquery",
  "lib/util"
],
function(
  $,
  Util
)
{
  "use strict";

  /* Ajax event handling */
  var onAjaxSend = function() {
    Util.JQuery.spinStart();
  };

  var onAjaxComplete = function() {
    Util.JQuery.spinStop();
  };

  $( function() {
    $(document).on( "ajaxSend", onAjaxSend )
               .on( "ajaxComplete", onAjaxComplete );

  } );
} );
