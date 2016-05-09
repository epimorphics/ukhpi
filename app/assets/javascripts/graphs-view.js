/** Component for showing the queried index data as a set of graphs */

modulejs.define( "graphs-view", [
  "lib/lodash",
  "lib/jquery",
  "lib/d3",
  "lib/util",
  "preferences",
  "aspects"
], function(
  _,
  $,
  D3,
  Util,
  Preferences,
  Aspects
) {
  "use strict";

  var GraphView = function() {
    this.preferences = new Preferences();
    this.graphConf = {};
  };

  var SERIES_MARKER = {
    "":               "circle",
    "Detached":       "diamond",
    "SemiDetached":   "square",
    "Terraced":       "triangle-down",
    "FlatMaisonette": "triangle-up"
  };

  var GRAPHS_OPTIONS = {
    averagePrice: {
      cssClass: "average-price",
      ticksCount: 5,
      yDomain: "",
      graphType: "lineAndPoints"
    },
    housePriceIndex: {
      cssClass: "house-price-index",
      ticksCount: 5,
      yDomain: "",
      graphType: "lineAndPoints"
    },
    percentageMonthlyChange: {
      cssClass: "percentage-monthly-change",
      ticksCount: 5,
      yDomain: "",
      graphType: "bars",
      symmetricalYAxis: true
    }
  };

  var GRAPH_PADDING = {
    top: 30,
    right: 20,
    bottom: 20,
    left: 80
  };
  GRAPH_PADDING.horizontal = GRAPH_PADDING.left + GRAPH_PADDING.right;
  GRAPH_PADDING.vertical = GRAPH_PADDING.top + GRAPH_PADDING.bottom;

  /** Width of graph bars, in pixels */
  var BAR_MARGIN = 1;
  var VISIBLE_BAR_WIDTH = 3;;
  var BAR_WIDTH = VISIBLE_BAR_WIDTH + BAR_MARGIN;
  var HALF_BAR_WIDTH = BAR_WIDTH / 2;

  /** Minimum height of graph bars (so that zero values are still visible) */
  var MIN_BAR_HEIGHT = 2;

  /* Methods */

  _.extend( GraphView.prototype, {
    prefs: function() {
      return this.preferences;
    },

    showQueryResults: function( qr ) {
      var gv = this;
      var dateRange = qr.dateRange();

      _.each( this.prefs().indicators(), function( indicator ) {
        var options = GRAPHS_OPTIONS[indicator];
        if (options) {
          gv.graphConf[indicator] = {};
          var graphConf = gv.graphConf[indicator];

          graphConf.elem = revealGraphElem( options );
          graphConf.root = drawGraphRoot( graphConf );

          var valueRange = calculateValueRange( indicator, gv.prefs(), qr, options );
          _.merge( graphConf, configureAxes( graphConf, dateRange, valueRange, options ) );
          drawAxes( graphConf );
          drawGraph( indicator, gv.prefs(), qr, graphConf, options );
        }
      } );
    }
  } );


  /* Helper functions */

  var revealGraphElem = function( options ) {
    var selector = ".js-graph." + options.cssClass;
    $( selector )
      .removeClass( "hidden" )
      .find( "svg" )
      .empty();
    return D3.select( selector + " svg" );
  };

  var configureAxes = function( graphConf, dateRange, valueRange, options ) {
    var scales = createScales( graphConf.elem );
    var axes = createAxes( scales, options );

    setScaleDomain( scales, dateRange, valueRange );

    return {
      scales: scales,
      axes: axes
    };
  };

  var createScales = function( graphElem ) {
    var xScale = D3.time.scale().nice(D3.time.month);
    var yScale = D3.scale.linear();
    return setScaleViewDimensions( xScale, yScale, graphElem );
  };

  var setScaleViewDimensions = function( xScale, yScale, elem ) {
    var width = parseInt( elem.style("width") ) - GRAPH_PADDING.horizontal;
    var height = parseInt( elem.style("height") ) - GRAPH_PADDING.vertical;

    xScale.range( [0, width] );
    yScale.range( [height, 0] );

    return {x: xScale, y: yScale, width: width, height: height};
  };

  var createAxes = function( scales, options ) {
    var xAxis = D3.svg.axis()
      .scale( scales.x )
      .orient("bottom")
      .tickFormat(D3.time.format("%b %Y"))
      .ticks( 8 );

    var yAxis = D3.svg.axis()
      .scale( scales.y )
      .orient("left")
      .ticks( options.ticksCount );

    return {x: xAxis, y: yAxis};
  };

  var setScaleDomain = function( scales, dateRange, valueRange ) {
    scales.x.domain( dateRange ).nice();
    scales.y.domain( valueRange ).nice();
  };

  var calculateValueRange = function( indicator, prefs, qr, options ) {
    var aspects = aspectNames( indicator, prefs );
    var extents = _.map( aspects, function( aspect ) {
      return D3.extent( qr.results(), function( result ) {
        return result.value( aspect );
      } );
    } );

    var overallRange = D3.extent( _.flatten( extents ) );

    if (options.symmetricalYAxis) {
      var largest = _.max( _.map( overallRange, Math.abs ) );
      return [largest * -1.0, largest];
    }
    else {
      return [0, overallRange[1]];
    }
  };

  var aspectNames = function( indicator, prefs ) {
    var aspects = prefs.aspects( {indicators: [indicator]} );
    return _.map( aspects, function( a ) {return "ukhpi:" + a;} );
  };

  var drawGraphRoot = function( graphConf ) {
    return graphConf
      .elem
      .append("g")
      .attr("transform", "translate(" + GRAPH_PADDING.left + "," + GRAPH_PADDING.top + ")");
  };

  var drawAxes = function( graphConf ) {
    graphConf.root
      .append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + graphConf.scales.height + ")")
      .call( graphConf.axes.x );
    graphConf.root
      .append("g")
      .attr("class", "y axis")
      .call( graphConf.axes.y );
  };

  var categoryCssClass = function( categoryName ) {
    return Util.Text.unCamelCase( categoryName, "-" ).toLocaleLowerCase();
  };

  var drawGraph = function( indicator, prefs, qr, graphConf, options ) {
    switch (options.graphType) {
    case "lineAndPoints":
      drawPoints( indicator, prefs, qr, graphConf, options );
      drawLine( indicator, prefs, qr, graphConf );
      break;
    case "bars":
      drawBars( indicator, prefs, qr, graphConf );
      break;
    default:
      console.log( "Unknown graph type" );
    }
  };

  var collectedSeries = function( indicator, prefs, qr ) {
    var s = _.map( prefs.categories(), function( c, i ) {
      var series = qr.series( indicator, c );
      _.each( series, function( d ) {d.categoryIndex = i;} );

      return series;
    } );

    return _.flatten( s );
  };

  var drawPoints = function( indicator, prefs, qr, graphConf, options ) {
    var x = graphConf.scales.x;
    var y = graphConf.scales.y;
    var data = collectedSeries( indicator, prefs, qr );

    graphConf.root
      .selectAll(".point")
      .data( data )
      .enter()
      .append("path")
      .attr("class", function( d ) {return "point " + categoryCssClass( d.cat );} )
      .attr("d", function( d, i ) {return D3.svg.symbol().type( SERIES_MARKER[d.cat] )( d, i );} )
      .attr("transform", function(d) { return "translate(" + x(d.x) + "," + y(d.y) + ")"; });

  };

  var drawLine = function( indicator, prefs, qr, graphConf ) {
    var x = graphConf.scales.x;
    var y = graphConf.scales.y;

    var line = D3.svg
      .line()
      .x( function(d) { return x( d.x ); } )
      .y( function(d) { return y( d.y ); } );

    _.each( prefs.categories(), function( c ) {
      var s = qr.series( indicator, c );
      graphConf.root
        .append( "path" )
        .datum( s )
        .attr( "class", "line " + categoryCssClass( c ) )
        .attr( "d", line );
    } );
  };

  var drawBars = function( indicator, prefs, qr, graphConf ) {
    var x = graphConf.scales.x;
    var y = graphConf.scales.y;
    var y0 = y( 0 );

    var offsets = barOffsets( prefs.categories().length );
    var data = collectedSeries( indicator, prefs, qr );

    graphConf.root
      .selectAll( ".bar" )
      .data( data )
      .enter()
      .append( "rect" )
      .attr( "class", function( d ) {return "bar " + categoryCssClass( d.cat );} )
      .attr( "x", function( d ) { return x( d.x ) + offsets[d.categoryIndex]; })
      .attr( "y", function( d ) { return y( Math.max( 0, d.y ) ); })
      .attr( "width", VISIBLE_BAR_WIDTH )
      .attr( "height", function( d ) {return Math.max( MIN_BAR_HEIGHT, Math.abs( y( d.y ) - y0 ) );} );
  };

  /** @return An array of the offsets around 0 for n category bars */
  var barOffsets = function( nPrefs ) {
    var lower = (nPrefs - 1) * HALF_BAR_WIDTH * -1.0;
    var upper = nPrefs * HALF_BAR_WIDTH;
    return _.range( lower, upper, BAR_WIDTH );
  };


  return GraphView;
} );
