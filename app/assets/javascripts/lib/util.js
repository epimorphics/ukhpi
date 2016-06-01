/**
 * General utilities
 * =================
 *
 * Arrays.toArray - ensure argument(s) are wrapped as an array
 *
 * URL.searchParams - return given (or current window) search params as an object
 * URL.searchParam - return value of named search param
 * URL.setSearchParams - update the given (or current window) search params
 * URL.setSearchParam - update a named search param
 *
 * Text.nonBreakingSpaces - map space char to HTML non-breaking space
 * Text.unCamelCase - split word at case boundaries
 *
 * Browser.isXX - test if current browser is Firefox, Safari, etc
 *
 * Event.preventDefault - prevent default action on event, and ensure flag is set
 *
 * Dates.daysOfMonth - return an array of the days of a given month
 */

/* jshint quotmark: double */
/* global define */


modulejs.define( "lib/util",
[
  "lib/lodash",
  "lib/jquery"
],
function(
  _,
  $
) {
  "use strict";

  /** Utilities for arrays */
  var Arrays = (function() {
    /** Ensure the return value is an array */
    var toArray = function() {
      if (arguments.length === 1) {
        return _.isArray( arguments[0] ) ? arguments[0] : [arguments[0]];
      }
      else {
        return Array.prototype.slice.call(arguments);
      }
    };

    return {
      toArray: toArray
    };
  }());

  /** Utilities for manipulating URLs */
  var URL = (function() {
    /**
     * Return an object containing one key for every distinct query
     * parameter, with also a `_vars` key which lists the query parameter
     * variables in order. Keys and values will be automatically
     * unescaped.
     * @param location The current location object. If null, window.location
     *                 will be used.
     */
    var searchParams = function( location ) {
      var loc = location || window.location;
      var env = {};

      if (loc.search) {
        var url = loc.search
                     .replace( /^\?/, "" )
                     .replace( /\+/g, " " );
        var args = url.split("&");

        for(var i = 0; i < args.length; i++) {
          var argPair = args[i].split("=");

          var key = decodeURIComponent( argPair[0] );
          var val = argPair.length > 1 ? decodeURIComponent( argPair[1] ) : null;

          if (env[key]) {
            env[key] = Arrays.toArray( env[key] );
            env[key].push( val );
          }
          else {
            env[key] = val;
          }
        }
      }

      return env;
    };

    /**
     * Return the value of the given search parameter from the url query string,
     * if defined.
     * @param v The name of the variable to retrieve
     * @param location The location object; if null, default to window.location
     */
    var searchParam = function( v, location ) {
      return searchParams( location )[v];
    };

    /**
     * Set zero or more URL variables to the values given by object vars
     * @param vars An object whose keys will become keys in location.search
     * @param location The location object; if null, default to window.location
     * @param omits Optional array of keys whose values should be removed before
     *              applying the updates from location
     */
    var setSearchParams = function( vars, location, omits ) {
      var loc = location || window.location;
      var uVars = searchParams( location );
      var newVars = _.extend( {}, _.omit( uVars, omits ), vars );

      var pairs = [];
      _.each( newVars, function( val, p ) {
        var key = encodeURIComponent( String( p ) );

        _.each( Arrays.toArray( val ), function( av ) {
          pairs.push( [key, encodeURIComponent( String( av ) )] );
        } );
      });

      var search = _.map( pairs, function( pair ) {return pair.join( "=" );} )
                    .join( "&" );

      loc.search = "?" + search;
    };

    /**
     * Set a URL search parameter, replacing any value that exists
     */
    var setSearchParam = function( p, v, loc ) {
      var vars = {};
      vars[p] = v;
      setSearchParams( vars, loc );
    };

    /** Update the search string component of a URL */
    var updateSearchString = function( url, searchParams ) {
      var matches = String( url ).match( /^([^\?]*\??)(.*)$/ );
      var pairs =
        matches[2] ?
          _.map( matches[2].split( "&" ), function( pair ) {return pair.split("=");} ) :
          [];
      var seen = [];

      _.forEach( searchParams, function( v, k ) {
        _.forEach( pairs, function( p ) {
          if (p[0] === k) {
            p[1] = v;
            seen.push( k );
          }
        } );
      } );

      _.forEach( searchParams, function( v, k ) {
        if (!_.includes( seen, k )) {
          pairs.push( [k,v] );
        }
      } );

      var queryCh = (pairs.length === 0 || matches[1].match( /\?$/ )) ? "" : "?";
      return matches[1] + queryCh + _.map( pairs, function( p ) {return p.join("=");} ).join("&");
    };

    /** @return The fragment identifier from the location URL, or null */
    var fragmentId = function( location ) {
      var h = (location || window.location).hash;
      return h ? h.slice(1) : null;
    };

    /* Module return */
    return {
      fragmentId: fragmentId,
      searchParams: searchParams,
      searchParam: searchParam,
      setSearchParams: setSearchParams,
      setSearchParam: setSearchParam,
      updateSearchString: updateSearchString
    };
  }());

  /** Text (ie String) handling utilities */
  var Text = (function() {
    /** Replace all spaces with non-breaking space characters */
    var nonBreakingSpaces = function( s ) {
        return s.replace( / /g, "&nbsp;" );
    };

    /** Change a camel-case word to separate tokens */
    var unCamelCase = function( str, sep ) {
      if (_.isString( str )) {
        var s = sep || " ";
        return str.replace( /([a-z])([A-Z])/g, function( str, p1, p2 ) {
            return p1 + s + p2.toLocaleLowerCase();
        } );
      }
      else {
        return str;
      }
    };

    /** @return A string will all tags replaced by the given string, default is space */
    var deHtml = function( s, r ) {
      r = r || " ";
      return s.replace( /<[^>]*>/g, r );
    };

    /** Convert white space in a string to HTML break elements */
    var forceBreaks = function( s ) {
      return s.replace( / /g, "<br />" );
    };

    return {
      deHtml: deHtml,
      forceBreaks: forceBreaks,
      nonBreakingSpaces: nonBreakingSpaces,
      unCamelCase: unCamelCase
    };
  }());

  /** Browser introspection utilities */
  var Browser = (function() {
    var testCSS =  function(prop) {
        return prop in document.documentElement.style;
    };

    var isOpera = function() {return !!(window.opera && window.opera.version);};  // Opera 8.0+
    var isFirefox = function() {return testCSS("MozBoxSizing");};                 // FF 0.8+
    var isSafari = function() {return Object.prototype.toString.call(window.HTMLElement).indexOf("Constructor") > 0;};    // At least Safari 3+: "[object HTMLElementConstructor]"
    var isChrome = function() {return !isSafari() && testCSS("WebkitTransform");};  // Chrome 1+
    var isIE = function() {return /*@cc_on!@*/false || testCSS("msTransform");};  // At least IE6

    var viewportSize = function() {
      var documentElement = document.documentElement;
      return {
        w: Math.max( documentElement.clientWidth, window.innerWidth || 0 ),
        h: Math.max( documentElement.clientHeight, window.innerHeight || 0 )
      };
    };

    /** @return True if the viewport width is no larger than the maximum for small viewports, default 768px */
    var isViewportSmall = function( smallMax ) {
      return viewportSize().w < (smallMax || 768);
    };

    /** @return True if the window or session store is available */
    var storageAvailable = function( type ) {
      try {
        var storage = window[type];
        var x = '__storage_test__';
        storage.setItem(x, x);
        storage.removeItem(x);
        return true;
      }
      catch(e) {
        return false;
      }
    };

    /** @return True if we were able to set the given key/value pair in session storage */
    var setSessionStore = function( key, value ) {
      if (storageAvailable( "sessionStorage" )) {
        window.sessionStorage.setItem( key, value );
        return true;
      }
      else {
        return false;
      }
    };

    /** @return The value of the key from session storage, if available */
    var getSessionStore = function( key ) {
      return storageAvailable( "sessionStorage" ) && window.sessionStorage.getItem( key );
    };

    return {
      isChrome: isChrome,
      isFirefox: isFirefox,
      isIE: isIE,
      isOpera: isOpera,
      isSafari: isSafari,
      isViewportSmall: isViewportSmall,
      getSessionStore: getSessionStore,
      setSessionStore: setSessionStore,
      viewportSize: viewportSize
    };
  }());

  /** Event utilities */
  var Event = (function() {
    /** Prevent the default action on an event. Ensure that defaultPrevented is true,
     *  even on older browsers
     */
    var preventDefault = function( e ) {
      e.preventDefault();
      e.defaultPrevented = true;
    };

    return {
      preventDefault: preventDefault
    };
  }());

  /** JQuery utilities */
  var JQuery = (function() {
    /** Ensure a string would be interpreted by Jquery as a CSS class expression */
    var asCssClass = function( cls ) {
      var startsWithDot = cls.indexOf( "." ) === 0;
      return startsWithDot ? cls : ("." + cls);
    };

    var spinCount = 0;

    var DEFAULT_SPIN_OPTIONS = {
      color:"#ACCD40",
      lines: 12,
      radius: 20,
      length: 10,
      width: 4,
      bgColor: "white"
    };

    /* Start the spinner */
    var spinStart = function( options ) {
      spinCount = spinCount + 1;
      if (spinCount === 1) {
        $("body").spin( options || DEFAULT_SPIN_OPTIONS );
      }
    };

    /** Stop the spinner */
    var spinStop = function() {
      spinCount = Math.max( spinCount - 1, 0 );
      if (spinCount === 0) {
        $("body").spin( false );
      }
    };

    /** Set the cursor position in an input element */
    var setCursorPosition = function( selector, pos ) {
      $( selector ).each( function( i, elem ) {
        if (elem.setSelectionRange) {
          elem.setSelectionRange(pos, pos);
        }
        else if (elem.createTextRange) {
          var range = elem.createTextRange();
          range.collapse(true);
          range.moveEnd( "character", pos);
          range.moveStart( "character", pos);
          range.select();
        }
      } );
    };

    /** Set the cursor to the end of an input element */
    var setCursorPositionEnd = function( selector ){
      setCursorPosition( selector, $(selector).val().length );
    };

    return {
      DEFAULT_SPIN_OPTIONS: DEFAULT_SPIN_OPTIONS,
      asCssClass: asCssClass,
      setCursorPosition: setCursorPosition,
      setCursorPositionEnd: setCursorPositionEnd,
      spinStart: spinStart,
      spinStop: spinStop
    };
  }());

  /** Date utilities */
  var Dates = (function() {
    /**
     * Return an array of the days in a month, from 1 to 28,29,30 or 31
     * @param year Year as a 4-digit number
     * @param mongth As a number, Jan = 1, Feb = 2, etc
     */
    var daysOfMonth = function( year, month ) {
      var month0 = month - 1; // JavaScript months start at 0
      var date = new Date( year, month0, 1 );
      var result = [];

      while (date.getMonth() === month0) {
        var d = date.getDate();
        result.push( d );
        date.setDate( d + 1 );
      }

      return result;
    };


    return {
      daysOfMonth: daysOfMonth
    };
  } ());

  /** Exports */
  return {
    Arrays: Arrays,
    Browser: Browser,
    Dates: Dates,
    Event: Event,
    JQuery: JQuery,
    Text: Text,
    URL: URL
  };
});
