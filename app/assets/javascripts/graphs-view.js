/** Component for showing the queried index data as a set of graphs */

modulejs.define( "graphs-view", [
  "lib/lodash",
  "lib/jquery",
  "lib/d3",
  "lib/util",
  "constants",
  "preferences",
  "values"
], function(
  _,
  $,
  D3,
  Util,
  Constants,
  Preferences,
  Values
) {
  "use strict";

  var GraphView = function() {
    this.graphConf = {};
  };

  var SERIES_MARKER = {
    "":               "circle",
    "Detached":       "diamond",
    "SemiDetached":   "square",
    "Terraced":       "triangle-down",
    "FlatMaisonette": "triangle-up"
  };

  var oneDecimalPlace = D3.format( ".2g" );

  var GRAPHS_OPTIONS = {
    averagePrice: {
      cssClass: "average-price",
      ticksCount: 5,
      yDomain: "",
      graphType: "lineAndPoints",
      byPropertyType: true
    },
    housePriceIndex: {
      cssClass: "house-price-index",
      ticksCount: 5,
      yDomain: "",
      graphType: "lineAndPoints",
      byPropertyType: true
    },
    percentageChange: {
      cssClass: "percentage-monthly-change",
      ticksCount: 5,
      yDomain: "",
      graphType: "lineAndPoints",
      symmetricalYAxis: true,
      tickFormat: function( d) {return oneDecimalPlace( d ) + "%";},
      byPropertyType: true
    },
    percentageAnnualChange: {
      cssClass: "percentage-annual-change",
      ticksCount: 5,
      yDomain: "",
      graphType: "lineAndPoints",
      symmetricalYAxis: true,
      tickFormat: function( d) {return oneDecimalPlace( d ) + "%";},
      byPropertyType: true
    },
    salesVolume: {
      cssClass: "sales-volume",
      ticksCount: 5,
      yDomain: "",
      graphType: "lineAndPoints",
      byPropertyType: false
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

  /* Methods */

  _.extend( GraphView.prototype, {
    prefs: function() {
      return this.preferences;
    },

    resetGraphs: function( prefs ) {
      $(".js-graph").addClass( "hidden" );

      $(".c-graph-key li").addClass( "hidden" );
      _.each( prefs.categories(), function( category ) {
        $(".c-graph-key li.key-" + categoryCssClass( category )).removeClass( "hidden" );
      } );
    },

    showQueryResults: function( qr ) {
      var gv = this;
      var dateRange = qr.dateRange();
      var prefs = new Preferences();

      this.resetGraphs( prefs );

      _.each( prefs.visibleGraphTypes(), function( indicator ) {
        var options = GRAPHS_OPTIONS[indicator];
        if (options) {
          gv.graphConf[indicator] = {};
          var graphConf = gv.graphConf[indicator];

          graphConf.elem = revealGraphElem( options, qr.location() );
          graphConf.root = drawGraphRoot( graphConf );

          var valueRange = calculateValueRange( indicator, prefs, qr, options );
          _.merge( graphConf, configureAxes( graphConf, dateRange, valueRange, options ) );
          drawAxes( graphConf );
          drawGraph( indicator, prefs, qr, graphConf, options );
          drawOverlay( indicator, prefs, qr, graphConf );
        }
      } );
    }
  } );


  /* Helper functions */

  var revealGraphElem = function( options, location ) {
    var selector = ".js-graph." + options.cssClass;
    $( selector )
      .removeClass( "hidden" )
      .find( "svg" )
      .empty();
    $( selector )
      .find( ".c-graph-heading span" )
      .empty()
      .text( ": " + location );
    return D3.select( selector + " svg" );
  };

  var configureAxes = function( graphConf, dateRange, valueRange, options ) {
    var scales = createScales( graphConf.elem );
    var axes = createAxes( scales, options, graphConf );

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
      .ticks( options.ticksCount )
      .innerTickSize( -1 * scales.width );

    if (options.tickFormat) {
      yAxis = yAxis.tickFormat( options.tickFormat );
    }

    return {x: xAxis, y: yAxis};
  };

  var setScaleDomain = function( scales, dateRange, valueRange ) {
    scales.x.domain( dateRange ).nice();
    scales.y.domain( valueRange ).nice();
  };

  var calculateValueRange = function( indicator, prefs, qr, options ) {
    var aspects = options.byPropertyType ? aspectNames( indicator, prefs ) : ["ukhpi:" + indicator];
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
    var aspects = prefs.aspects( {indicators: [indicator], common: []} );
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
      if (options.byPropertyType) {
        drawPoints( indicator, prefs, qr, graphConf );
      }
      drawLine( indicator, prefs, qr, graphConf );
      break;
    default:
      console.log( "Unknown graph type" );
    }
  };

  var sampledSeries = function( indicator, prefs, qr ) {
    var s = _.map( prefs.categories(), function( c, i ) {
      var series = qr.series( indicator, c );
      var datum = _.sample( series );
      datum.categoryIndex = i;

      return datum;
    } );

    return s;
  };

  var drawPoints = function( indicator, prefs, qr, graphConf ) {
    var x = graphConf.scales.x;
    var y = graphConf.scales.y;
    var data = sampledSeries( indicator, prefs, qr );

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

  var formatAspect = function( indicator, cat, value ) {
    var catName = {
      "": "all ",
      "Detached": "det. ",
      "SemiDetached": "s.det. ",
      "Terraced": "terr. ",
      "FlatMaisonette": "f/m. "
    }[cat];
    return catName + Values.formatValue( indicator + cat, value );
  };

  var bisectDate = D3.bisector( function(d) { return d.x; } ).left;


  var drawOverlay = function( indicator, prefs, qr, graphConf ) {
    var categories = prefs.categories();

    var xTrack = graphConf
      .elem
      .append( "g" )
      .attr( "class", "c-x-track--g")
      .style( "display", "none" );
    xTrack
      .append( "rect" )
      .attr( "class", "c-x-track" )
      .attr( "height", graphConf.scales.height )
      .attr( "width", 0.5 )
      .attr( "stroke-dasharray", "5,5" )
      .attr( "y", GRAPH_PADDING.top );

    xTrack
      .append( "text" )
      .attr( "class", "c-x-track--title" )
      .attr( "y", 20 )
      .append( "dy", "0.35em" );

    graphConf
      .elem
      .append("rect")
      .attr("class", "c-graph-overlay")
      .attr("width", graphConf.scales.width)
      .attr("height", graphConf.scales.height)
      .attr("transform", "translate(" + GRAPH_PADDING.left + "," + GRAPH_PADDING.top + ")")
      .on("mouseover", function() { xTrack.style("display", null); })
      .on("mouseout", function() { xTrack.style("display", "none"); })
      .on("mousemove", (function() {
          return function() {onXTrackMouseMove.call( this, indicator, graphConf, categories, qr, xTrack );};
      })() );
  };

  var onXTrackMouseMove = function( indicator, graphConf, categories, qr, xTrack ) {
    var aSeries = qr.series( indicator, _.first( categories ) );

    var x = graphConf.scales.x;
    var x0 = x.invert( D3.mouse(this)[0] ),
        i = bisectDate( aSeries, x0, 1 ),
        d0 = aSeries[i - 1],
        d1 = aSeries[i],
        d = (d1 && (x0 - d0.x > d1.x - x0)) ? d1 : d0;
    xTrack.attr("transform", "translate(" + (GRAPH_PADDING.left + x(d.x)) + "," + 0 + ")");

    var label = D3.time.format("%b %Y")( d.x );
    label = label + ": " + _.map( categories, function( cat ) {
      var value = _.find( qr.series( indicator, cat ), {x: d.x} );
      return formatAspect( indicator, cat, value.y );
    } ).join( ", ");

    var txtLen = xTrack
      .select("text")
      .text( label )
      .node()
      .getComputedTextLength();

    var maxLeft = graphConf.scales.width - txtLen;
    var delta = maxLeft - x(d.x);
    if (delta < 0) {
      xTrack
        .select("text")
        .attr( "transform", "translate( " + delta + ", 0)" );
    }
  };

  return GraphView;
} );
