/** Component for showing the queried index data as a set of graphs */

import _ from 'lodash';
import D3 from 'd3';
// 'lib/util'
// 'lib/js-logger'
// 'constants'
// 'preferences'
// 'values'

const SERIES_MARKER = {
  '': 'circle',
  Detached: 'diamond',
  SemiDetached: 'square',
  Terraced: 'triangle-down',
  FlatMaisonette: 'triangle-up',
};

const oneDecimalPlace = D3 && D3.format('.2g');

const GRAPHS_OPTIONS = {
  averagePrice: {
    cssClass: 'average-price',
    ticksCount: 5,
    yDomain: '',
    graphType: 'lineAndPoints',
    tickFormat(d) { return Values.asCurrency(d); },
    byPropertyType: true,
  },
  housePriceIndex: {
    cssClass: 'house-price-index',
    ticksCount: 5,
    yDomain: '',
    graphType: 'lineAndPoints',
    byPropertyType: true,
  },
  percentageChange: {
    cssClass: 'percentage-monthly-change',
    ticksCount: 5,
    yDomain: '',
    graphType: 'lineAndPoints',
    symmetricalYAxis: true,
    tickFormat(d) { return `${oneDecimalPlace(d)}%`; },
    byPropertyType: true,
  },
  percentageAnnualChange: {
    cssClass: 'percentage-annual-change',
    ticksCount: 5,
    yDomain: '',
    graphType: 'lineAndPoints',
    symmetricalYAxis: true,
    tickFormat(d) { return `${oneDecimalPlace(d)}%`; },
    byPropertyType: true,
  },
  salesVolume: {
    cssClass: 'sales-volume',
    ticksCount: 5,
    yDomain: '',
    graphType: 'lineAndPoints',
    byPropertyType: false,
  },
};

const GRAPH_PADDING = {
  top: 10,
  right: 25,
  bottom: 20,
  left: 80,
};
GRAPH_PADDING.horizontal = GRAPH_PADDING.left + GRAPH_PADDING.right;
GRAPH_PADDING.vertical = GRAPH_PADDING.top + GRAPH_PADDING.bottom;

/* Helper functions */

function setNoGraphsMessage() {
  $('.c-graphs').html('<h2>No graphs in IE version 8</h2>' + '<p>We are sorry, but graphs of house-price ' +
    'indices are not available in your browser.</p>');
}

function showQueryResultGraphs(qr) {
  const gv = this;
  const prefs = new Preferences();
  const dateRange = qr.dateRange() || prefs.dateRange();

  this.resetGraphs(prefs);

  _.each(prefs.visibleGraphTypes(), (indicator) => {
    const options = GRAPHS_OPTIONS[indicator];
    if (options) {
      gv.graphConf[indicator] = {};
      const graphConf = gv.graphConf[indicator];

      graphConf.elem = revealGraphElem(options, qr.location());
      graphConf.root = drawGraphRoot(graphConf);

      const valueRange = calculateValueRange(indicator, prefs, qr, options);
      _.merge(graphConf, configureAxes(graphConf, dateRange, valueRange, options));
      drawAxes(graphConf, options);
      drawGraph(indicator, prefs, qr, graphConf, options);
      drawOverlay(indicator, prefs, qr, graphConf, options);
      addGraphNote(qr, options);
    }
  });
}

function revealGraphElem(options, location) {
  const selector = `.js-graph.${options.cssClass}`;
  $(selector)
    .removeClass('hidden')
    .find('svg')
    .empty();
  $(selector)
    .find('.c-graph-heading span')
    .empty()
    .html(`: ${location}`);
  return D3.select(`${selector} svg`);
}

function configureAxes(graphConf, dateRange, valueRange, options) {
  const scales = createScales(graphConf.elem);
  const axes = createAxes(scales, options, graphConf, monthsSpanned(dateRange));

  setScaleDomain(scales, dateRange, valueRange);

  return {
    scales,
    axes,
  };
}

function createScales(graphElem) {
  const xScale = D3.time.scale().nice(D3.time.month);
  const yScale = D3.scale.linear();
  return setScaleViewDimensions(xScale, yScale, graphElem);
}

var setScaleViewDimensions = function (xScale, yScale, elem) {
  const width = parseInt(elem.style('width')) - GRAPH_PADDING.horizontal;
  const height = parseInt(elem.style('height')) - GRAPH_PADDING.vertical;

  xScale.range([0, width]);
  yScale.range([height, 0]);

  return {
    x: xScale, y: yScale, width, height,
  };
};

function createAxes(scales, options, graphConf, nMonths) {
  let xAxis = D3.svg.axis()
    .scale(scales.x)
    .orient('bottom')
    .tickFormat(D3.time.format('%b %Y'));
  xAxis = xAxis.ticks(Math.min(nMonths, 8));

  let yAxis = D3.svg.axis()
    .scale(scales.y)
    .orient('left')
    .ticks(options.ticksCount)
    .innerTickSize(-1 * scales.width);

  if (options.tickFormat) {
    yAxis = yAxis.tickFormat(options.tickFormat);
  }

  return { x: xAxis, y: yAxis };
}

function setScaleDomain(scales, dateRange, valueRange) {
  scales.x.domain(dateRange).nice();
  scales.y.domain(valueRange).nice();
}

var calculateValueRange = function (indicator, prefs, qr, options) {
  const aspects = options.byPropertyType ? aspectNames(indicator, prefs) : [`ukhpi:${indicator}`];
  let extents = [0, 1.0];

  if (qr.size() > 0) {
    extents = _.map(aspects, aspect => D3.extent(qr.results(), result => result.value(aspect)));
  }

  const overallRange = D3.extent(_.flatten(extents));

  if (options.symmetricalYAxis) {
    let largest = _.max(_.map(overallRange, Math.abs));
    largest = Math.max(largest, 1.0);
    return [largest * -1.0, largest];
  }

  let limit = overallRange[1];
  limit = Math.max(limit, 100);
  return [0, limit];
};

function monthsSpanned(dateRange) {
  const year0 = dateRange[0].getFullYear();
  const year1 = dateRange[1].getFullYear();

  const month0 = dateRange[0].getMonth();
  const month1 = dateRange[1].getMonth();

  return (year1 - year0) * 12 + (month1 - month0 + 1);
}

var aspectNames = function (indicator, prefs) {
  const aspects = prefs.aspects({ indicators: [indicator], common: [] });
  return _.map(aspects, a => `ukhpi:${a}`);
};

function drawGraphRoot(graphConf) {
  return graphConf
    .elem
    .append('g')
    .attr('transform', `translate(${GRAPH_PADDING.left},${GRAPH_PADDING.top})`);
}

function drawAxes(graphConf, options) {
  graphConf.root
    .append('g')
    .attr('class', 'x axis')
    .attr('transform', translateCmd(0, graphConf.scales.height))
    .call(graphConf.axes.x);
  graphConf.root
    .append('g')
    .attr('class', 'y axis')
    .call(graphConf.axes.y);

  if (options.symmetricalYAxis) {
    graphConf.root
      .append('svg:line')
      .attr('class', 'x axis supplemental')
      .attr('x1', 0)
      .attr('x2', graphConf.scales.width)
      .attr('y1', graphConf.scales.y(0))
      .attr('y2', graphConf.scales.y(0));
  }
}

function categoryCssClass(categoryName) {
  return Util.Text.unCamelCase(categoryName, '-').toLocaleLowerCase();
}

function drawGraph(indicator, prefs, qr, graphConf, options) {
  switch (options.graphType) {
    case 'lineAndPoints':
      if (options.byPropertyType) {
        drawPoints(indicator, prefs, qr, graphConf);
      }
      drawLine(indicator, prefs, qr, graphConf, options);
      break;
    default:
      Log.warn(`Unknown graph type: ${options.graphType}`);
  }
}

function sampledSeries(indicator, prefs, qr) {
  const s = _.map(prefs.categories(), (c, i) => {
    const series = qr.series(indicator, c);
    const datum = _.sample(series);
    if (datum) {
      datum.categoryIndex = i;
      return datum;
    }

    return null;
  });

  return _.compact(s);
}

function drawPoints(indicator, prefs, qr, graphConf) {
  const x = graphConf.scales.x;
  const y = graphConf.scales.y;
  const data = sampledSeries(indicator, prefs, qr);

  graphConf.root
    .selectAll('.point')
    .data(data)
    .enter()
    .append('path')
    .attr('class', d => `point ${categoryCssClass(d.cat)}`)
    .attr('d', (d, i) => D3.svg.symbol().type(SERIES_MARKER[d.cat])(d, i))
    .attr('transform', d => translateCmd(x(d.x), y(d.y)));
}

function lineCategories(prefs, options) {
  return options.byPropertyType ? prefs.categories() : [''];
}

function drawLine(indicator, prefs, qr, graphConf, options) {
  const x = graphConf.scales.x;
  const y = graphConf.scales.y;

  const line = D3.svg
    .line()
    .x(d => x(d.x))
    .y(d => y(d.y));

  _.each(lineCategories(prefs, options), (c) => {
    const s = qr.series(indicator, c);
    graphConf.root
      .append('path')
      .datum(s)
      .attr('class', `line ${categoryCssClass(c)}`)
      .attr('d', line);
  });
}

function formatAspect(indicator, cat, value) {
  const catName = {
    '': 'all ',
    Detached: 'det. ',
    SemiDetached: 's.det. ',
    Terraced: 'terr. ',
    FlatMaisonette: 'f/m. ',
  }[cat];
  return catName + Values.formatValue(indicator + cat, value);
}

const bisectDate = D3 && D3.bisector(d => d.x).left;


function drawOverlay(indicator, prefs, qr, graphConf, options) {
  const categories = lineCategories(prefs, options);

  const xTrack = graphConf
    .elem
    .append('g')
    .attr('class', 'c-x-track--g')
    .style('display', 'none');
  xTrack
    .append('rect')
    .attr('class', 'c-x-track')
    .attr('height', graphConf.scales.height)
    .attr('width', 0.5)
    .attr('stroke-dasharray', '5,5')
    .attr('y', GRAPH_PADDING.top + 10);

  xTrack
    .append('text')
    .attr('class', 'c-x-track--title')
    .attr('y', 20)
    .append('dy', '0.35em');

  graphConf
    .elem
    .append('rect')
    .attr('class', 'c-graph-overlay')
    .attr('width', graphConf.scales.width)
    .attr('height', graphConf.scales.height)
    .attr('transform', translateCmd(GRAPH_PADDING.left, GRAPH_PADDING.top))
    .on('mouseover', () => { xTrack.style('display', null); })
    .on('mouseout', () => { xTrack.style('display', 'none'); })
    .on('mousemove', (function () {
      return function () { onXTrackMouseMove.call(this, indicator, graphConf, categories, qr, xTrack); };
    }()));
}

function onXTrackMouseMove(indicator, graphConf, categories, qr, xTrack) {
  if (qr.size() > 0) {
    onXTrackMouseMoveDraw.call(this, indicator, graphConf, categories, qr, xTrack);
  }
}

function onXTrackMouseMoveDraw(indicator, graphConf, categories, qr, xTrack) {
  const aSeries = qr.series(indicator, _.first(categories));

  const x = graphConf.scales.x;
  let x0 = x.invert(D3.mouse(this)[0]),
    i = bisectDate(aSeries, x0, 1),
    d0 = aSeries[i - 1],
    d1 = aSeries[i],
    d = (d1 && (x0 - d0.x > d1.x - x0)) ? d1 : d0;
  xTrack.attr('transform', translateCmd((GRAPH_PADDING.left + x(d.x)), -10));

  let label = D3.time.format('%b %Y')(d.x);
  label = `${label}: ${_.map(categories, (cat) => {
    const value = _.find(qr.series(indicator, cat), { x: d.x });
    return formatAspect(indicator, cat, value && value.y);
  }).join(', ')}`;

  const labelElem = xTrack.select('text');
  const txtLen = labelElem
    .text(label)
    .node()
    .getComputedTextLength();

  const maxLeft = graphConf.scales.width - txtLen;
  const delta = maxLeft - x(d.x);
  if (delta < 0) {
    labelElem.attr('transform', translateCmd(delta, 0));
  } else {
    labelElem.attr('transform', translateCmd(0, 0));
  }
}

function translateCmd(x, y) {
  return `translate(${parseInt(x)},${parseInt(y)})`;
}

function addGraphNote(qr, options) {
  const noteElem = $(`.js-graph.${options.cssClass} .js-graph-note`);
  const periodElem = $(`.js-graph.${options.cssClass} .js-percentage-period`);

  if (qr.duration() === 3) {
    noteElem.html('<p><strong>Note:</strong> these figures are reported quarterly not monthly.<p>');
    periodElem.text('quarterly');
  } else {
    noteElem.empty();
    periodElem.text('monthly');
  }
}

export default class GraphView {
  constructor() {
    this.graphConf = {};
  }

  prefs() {
    return this.preferences;
  }

  resetGraphs(prefs) {
    $('.js-graph').addClass('hidden');

    $('.c-graph-key li').addClass('hidden');
    _.each(prefs.categories(), (category) => {
      $(`.c-graph-key li.key-${categoryCssClass(category)}`).removeClass('hidden');
    });
  }

  showQueryResults(qr) {
    if (window.isIE8) {
      setNoGraphsMessage();
    } else {
      showQueryResultGraphs.call(this, qr);
    }
  }
}
