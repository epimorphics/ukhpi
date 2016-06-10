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

  var oneDecimalPlace = D3 && D3.format( ".2g" );

  var GRAPHS_OPTIONS = {
    averagePrice: {
      cssClass: "average-price",
      ticksCount: 5,
      yDomain: "",
      graphType: "lineAndPoints",
      tickFormat: function( d) {return Values.asCurrency( d );},
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
    top: 10,
    right: 25,
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
      if (window.isIE8) {
        setNoGraphsMessage();
      }
      else {
        showQueryResultGraphs.call( this, qr );
      }
    }
  } );


  /* Helper functions */

  var setNoGraphsMessage = function() {
    $(".c-graphs").html(
      "<h2>No graphs in IE version 8</h2>" + "<p>We are sorry, but graphs of house-price " +
      "indices are not available in your browser.</p>" );
  };

  var showQueryResultGraphs = function( qr ) {
    var gv = this;
    var prefs = new Preferences();
    var dateRange = qr.dateRange() || prefs.dateRange();

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
        drawAxes( graphConf, options );
        drawGraph( indicator, prefs, qr, graphConf, options );
        drawOverlay( indicator, prefs, qr, graphConf, options );
        addGraphNote( qr, options );
      }
    } );
  };

  var revealGraphElem = function( options, location ) {
    var selector = ".js-graph." + options.cssClass;
    $( selector )
      .removeClass( "hidden" )
      .find( "svg" )
      .empty();
    $( selector )
      .find( ".c-graph-heading span" )
      .empty()
      .html( ": " + location );
    return D3.select( selector + " svg" );
  };

  var configureAxes = function( graphConf, dateRange, valueRange, options ) {
    var scales = createScales( graphConf.elem );
    var axes = createAxes( scales, options, graphConf, monthsSpanned( dateRange ) );

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

  var createAxes = function( scales, options, graphConf, nMonths ) {
    var xAxis = D3.svg.axis()
      .scale( scales.x )
      .orient("bottom")
      .tickFormat(D3.time.format("%b %Y"));
    xAxis = xAxis.ticks( Math.min( nMonths, 8 ) );

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
    var extents = [0,1.0];

    if (qr.size() > 0) {
      extents = _.map( aspects, function( aspect ) {
        return D3.extent( qr.results(), function( result ) {
          return result.value( aspect );
        } );
      } );
    }

    var overallRange = D3.extent( _.flatten( extents ) );

    if (options.symmetricalYAxis) {
      var largest = _.max( _.map( overallRange, Math.abs ) );
      largest = Math.max( largest, 1.0 );
      return [largest * -1.0, largest];
    }
    else {
      var limit = overallRange[1];
      limit = Math.max( limit, 100 );
      return [0, limit];
    }
  };

  var monthsSpanned = function( dateRange ) {
    var year0 = dateRange[0].getFullYear();
    var year1 = dateRange[1].getFullYear();

    var month0 = dateRange[0].getMonth();
    var month1 = dateRange[1].getMonth();

    return (year1 - year0) * 12 + (month1 - month0 + 1);
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

  var drawAxes = function( graphConf, options ) {
    graphConf.root
      .append("g")
      .attr("class", "x axis")
      .attr("transform", translateCmd( 0, graphConf.scales.height ))
      .call( graphConf.axes.x );
    graphConf.root
      .append("g")
      .attr("class", "y axis")
      .call( graphConf.axes.y );

    if (options.symmetricalYAxis) {
      graphConf.root
        .append("svg:line")
        .attr( "class", "x axis supplemental" )
        .attr( "x1", 0 )
        .attr( "x2", graphConf.scales.width )
        .attr( "y1", graphConf.scales.y( 0 ) )
        .attr( "y2", graphConf.scales.y( 0 ) );
    }
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
      drawLine( indicator, prefs, qr, graphConf, options );
      break;
    default:
      console.log( "Unknown graph type" );
    }
  };

  var sampledSeries = function( indicator, prefs, qr ) {
    var s = _.map( prefs.categories(), function( c, i ) {
      var series = qr.series( indicator, c );
      var datum = _.sample( series );
      if (datum) {
        datum.categoryIndex = i;
        return datum;
      }
      else {
        return null;
      }
    } );

    return _.compact( s );
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
      .attr("transform", function(d) { return translateCmd( x(d.x), y(d.y) );});

  };

  var lineCategories = function( prefs, options ) {
    return options.byPropertyType ? prefs.categories() : [""];
  };

  var drawLine = function( indicator, prefs, qr, graphConf, options ) {
    var x = graphConf.scales.x;
    var y = graphConf.scales.y;

    var line = D3.svg
      .line()
      .x( function(d) { return x( d.x ); } )
      .y( function(d) { return y( d.y ); } );

    _.each( lineCategories( prefs, options ), function( c ) {
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

  var bisectDate = D3 && D3.bisector( function(d) { return d.x; } ).left;


  var drawOverlay = function( indicator, prefs, qr, graphConf, options ) {
    var categories = lineCategories( prefs, options );

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
      .attr( "y", GRAPH_PADDING.top + 10 );

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
      .attr("transform", translateCmd( GRAPH_PADDING.left, GRAPH_PADDING.top ) )
      .on("mouseover", function() { xTrack.style("display", null); })
      .on("mouseout", function() { xTrack.style("display", "none"); })
      .on("mousemove", (function() {
          return function() {onXTrackMouseMove.call( this, indicator, graphConf, categories, qr, xTrack );};
      })() );
  };

  var onXTrackMouseMove = function( indicator, graphConf, categories, qr, xTrack ) {
    if (qr.size() > 0) {
      onXTrackMouseMoveDraw( indicator, graphConf, categories, qr, xTrack );
    }
  };

  var onXTrackMouseMoveDraw = function( indicator, graphConf, categories, qr, xTrack ) {
    var aSeries = qr.series( indicator, _.first( categories ) );

    var x = graphConf.scales.x;
    var x0 = x.invert( D3.mouse(this)[0] ),
        i = bisectDate( aSeries, x0, 1 ),
        d0 = aSeries[i - 1],
        d1 = aSeries[i],
        d = (d1 && (x0 - d0.x > d1.x - x0)) ? d1 : d0;
    xTrack.attr("transform", translateCmd( (GRAPH_PADDING.left + x(d.x)), -10 ) );

    var label = D3.time.format("%b %Y")( d.x );
    label = label + ": " + _.map( categories, function( cat ) {
      var value = _.find( qr.series( indicator, cat ), {x: d.x} );
      return formatAspect( indicator, cat, value && value.y );
    } ).join( ", ");

    var labelElem = xTrack.select( "text" );
    var txtLen = labelElem
      .text( label )
      .node()
      .getComputedTextLength();

    var maxLeft = graphConf.scales.width - txtLen;
    var delta = maxLeft - x(d.x);
    if (delta < 0) {
      labelElem.attr( "transform", translateCmd( delta, 0 ) );
    }
    else {
      labelElem.attr( "transform", translateCmd( 0, 0 ) );
    }
  };

  var translateCmd = function( x, y ) {
    return "translate(" + parseInt( x ) + "," + parseInt( y ) + ")";
  };

  var addGraphNote = function( qr, options ) {
    var noteElem = $(".js-graph." + options.cssClass + " .js-graph-note" );
    var periodElem = $(".js-graph." + options.cssClass + " .js-percentage-period" );

    if (qr.duration() === 3) {
      noteElem.html( "<p><strong>Note:</strong> these figures are reported quarterly not monthly.<p>" );
      periodElem.text( "quarterly" );
    }
    else {
      noteElem.empty();
      periodElem.text( "monthly" );
    }
  };

  return GraphView;
} );
