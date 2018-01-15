/** Component for showing the queried index data as a set of graphs */

import _ from 'lodash';
import Raven from 'raven-js';
import { axisBottom, axisLeft } from 'd3-axis';
import { extent, bisector } from 'd3-array';
import { format } from 'd3-format';
import { scaleLinear, scaleTime } from 'd3-scale';
import { mouse, select } from 'd3-selection';
import { line, symbol, symbolCircle, symbolDiamond, symbolStar,
  symbolTriangle, symbolSquare } from 'd3-shape';
import { timeMonth } from 'd3-time';
import { timeFormat } from 'd3-time-format';
import { interpolateNumber } from 'd3-interpolate';
import { asCurrency, formatValue } from '../lib/values';
import bus from '../lib/event-bus';

const SERIES_MARKER = [
  symbolCircle,
  symbolDiamond,
  symbolSquare,
  symbolStar,
  symbolTriangle,
];

/** Move line markers this many days along the x-axis, per series */
const MARKER_OFFSET = {
  mult: 6,
  constant: 2,
};

const oneDecimalPlace = format('.2g');

const GRAPH_OPTIONS = {
  averagePrice: {
    cssClass: 'average-price',
    ticksCount: 5,
    yDomain: '',
    graphType: 'lineAndPoints',
    tickFormat(d) { return asCurrency(d); },
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
  top: 20,
  right: 25,
  bottom: 30,
  left: 65,
};
GRAPH_PADDING.horizontal = GRAPH_PADDING.left + GRAPH_PADDING.right;
GRAPH_PADDING.vertical = GRAPH_PADDING.top + GRAPH_PADDING.bottom;

const MIN_XAXIS_MONTHS = 8;

/* Helper functions */

/** Create or re-create the root SVG node that the graph will be drawn into */
function drawGraphRoot(graphConfig) {
  const { elementId } = graphConfig;
  const svgRoot = select(`#${elementId}`);

  svgRoot.select('g').remove();

  const rootElem = svgRoot
    .append('g')
    .attr('transform', `translate(${GRAPH_PADDING.left},${GRAPH_PADDING.top})`);

  return { svgRoot, rootElem };
}

/** @return True if the given statistic is selected for display */
function isSelectedStatistic(statistic, graphConfig) {
  return graphConfig.selectedStatistics[statistic.slug || statistic];
}

/** @return The currently visible statistics */
function visibleStatistics(graphConfig) {
  return graphConfig.theme.statistics.filter(stat => isSelectedStatistic(stat, graphConfig));
}

/** @return The range of values in the projection of the selected statistics */
function calculateValueRange(projection, graphConfig) {
  let [min, max] = [0.0, 1.0];

  _.each(graphConfig.theme.statistics, (statistic) => {
    const projected = projection[statistic.slug];
    if (isSelectedStatistic(statistic, graphConfig) && projected.length > 0) {
      const yDomain = projected.map(datum => datum.y);
      const [lo, hi] = extent(yDomain);
      min = Math.min(min, lo);
      max = Math.max(max, hi);
    }
  });

  if (graphConfig.symmetricalYAxis) {
    const largest = Math.max(Math.abs(min), Math.abs(max));
    [min, max] = [largest * -1.0, largest];
  }

  return [min, max];
}

/** Create a pair of scales to range across the height and width of the viewport
 * for the root node, minus the surrounding padding */
function createScales(graphConfig) {
  const parentWidth = graphConfig.svgRoot.node().parentNode.offsetWidth;
  const parentHeight = graphConfig.svgRoot.node().parentNode.offsetHeight;

  const xScale = scaleTime().nice(timeMonth);
  const width = parentWidth - GRAPH_PADDING.horizontal;
  xScale.domain(graphConfig.dateRange).nice();
  xScale.range([0, width]);

  const yScale = scaleLinear();
  const height = parentHeight - GRAPH_PADDING.vertical;
  yScale.domain(graphConfig.valueRange).nice();
  yScale.range([height, 0]);

  return {
    x: xScale, y: yScale, width, height,
  };
}

/** Create x and y axes, given the scales and options for tick formatting etc */
function createAxes(scales, graphConfig) {
  let xAxis = axisBottom(scales.x)
    .tickPadding(5)
    .tickFormat(timeFormat('%b %Y'));
  xAxis = xAxis.ticks(Math.min(graphConfig.period, MIN_XAXIS_MONTHS));

  let yAxis = axisLeft(scales.y)
    .ticks(graphConfig.ticksCount)
    .tickPadding(8)
    .tickSizeInner(-1 * scales.width);

  if (graphConfig.tickFormat) {
    yAxis = yAxis.tickFormat(graphConfig.tickFormat);
  }

  return { x: xAxis, y: yAxis };
}

/** Configure the axes for the graph */
function configureAxes(graphConfig) {
  const scales = createScales(graphConfig);
  const axes = createAxes(scales, graphConfig);

  return {
    scales,
    axes,
  };
}

function translateCmd(x, y) {
  return `translate(${parseInt(x, 10)},${parseInt(y, 10)})`;
}

/** Draw the graph axes onto the SVG element */
function drawAxes(graphConfig) {
  graphConfig.rootElem
    .append('g')
    .attr('class', 'x axis')
    .attr('transform', translateCmd(0, graphConfig.scales.height))
    .call(graphConfig.axes.x);
  graphConfig.rootElem
    .append('g')
    .attr('class', 'y axis')
    .call(graphConfig.axes.y);

  if (_.isNaN(graphConfig.scales.y(0))) {
    return;
  }

  if (graphConfig.symmetricalYAxis) {
    graphConfig.rootElem
      .append('svg:line')
      .attr('class', 'y axis supplemental')
      .attr('x1', 0)
      .attr('x2', graphConfig.scales.width)
      .attr('y1', graphConfig.scales.y(0))
      .attr('y2', graphConfig.scales.y(0));
  }

  // add a clickable region for changing the dates
  graphConfig.rootElem
    .append('rect')
    .attr('height', 20)
    .attr('width', graphConfig.scales.width + GRAPH_PADDING.right)
    .attr('transform', translateCmd(0, graphConfig.scales.height))
    .attr('class', 'o-x-axis-click-target')
    .on('click', () => bus.$emit('change-dates'));
}

/** Draw a marker to distinguish a series other than by colour */
function drawPoints(series, index, graphConfig) {
  const { scales } = graphConfig;
  if (series.length < 1) {
    return;
  }
  const { x: x0, y: y0 } = series[0];
  const { y: y1 } = series.length > 1 ? series[1] : series[0];
  const interpolation = interpolateNumber(y0, y1);

  // create a point that progressively further from the y-axis
  const xDelta = new Date(x0);
  const delta = (index * MARKER_OFFSET.mult) + MARKER_OFFSET.constant;
  const iDelta = delta / 31; // interpolation requires a number on [0, 1.0]

  if (series.length > 1) {
    xDelta.setDate(xDelta.getDate() + delta);
  }

  const cssClass = `point v-graph-${index}`;

  graphConfig.rootElem
    .selectAll(cssClass)
    .data([{ x: xDelta, y: interpolation(iDelta) }])
    .enter()
    .append('path')
    .attr('class', cssClass)
    .attr('d', (d, i) => symbol().type(SERIES_MARKER[index])(d, i))
    .attr('transform', d => translateCmd(scales.x(d.x), scales.y(d.y)));
}

/** Draw an SVG path representing the selected indicator as a line */
function drawLine(series, index, graphConfig) {
  const { x, y } = graphConfig.scales;

  const ln = line()
    .x(d => x(d.x))
    .y(d => y(d.y));

  graphConfig.rootElem
    .append('path')
    .datum(series)
    .attr('class', `line v-graph-${index}`)
    .attr('d', ln);
}

/** Draw the lines or other forms used to portray the data series */
function drawGraphLines(series, index, graphConfig) {
  switch (graphConfig.graphType) {
    case 'lineAndPoints':
      drawPoints(series, index, graphConfig);
      drawLine(series, index, graphConfig);
      break;
    default:
      Raven.captureMessage(`Unknown graph type: ${graphConfig.graphType}`);
  }
}

const bisectDate = bisector(d => d.x).left;

function formatStatistic(indicator, statistic, value) {
  const abbrev = {
    all: 'all ',
    det: 'det. ',
    sem: 's.det. ',
    ter: 'terr. ',
    fla: 'f/m. ',
  }[statistic.slug];
  return (abbrev || statistic.label) + formatValue(indicator + statistic, value);
}

function xTrackLabel(statistic, projection, graphConfig, d) {
  const series = projection[statistic.slug];
  const value = _.find(series, { x: d.x });
  return formatStatistic(graphConfig.indicatorId, statistic, value && value.y);
}

/** Track mouse movement and update the overlay */
function onXTrackMouseMove(projection, graphConfig, xTrack) {
  const aSeries = _.first(_.values(projection));
  if (_.isEmpty(aSeries)) {
    return;
  }

  const { x } = graphConfig.scales;
  const x0 = x.invert(mouse(graphConfig.rootElem.node())[0]);

  const i = bisectDate(aSeries, x0, 1);
  const d0 = aSeries[i - 1];
  const d1 = aSeries[i];
  const d = (d1 && (x0 - d0.x > d1.x - x0)) ? d1 : d0;
  xTrack.attr('transform', translateCmd(x(d.x), -10));

  const dateLabel = timeFormat('%b %Y')(d.x);
  const labeller = (() => (statistic => xTrackLabel(statistic, projection, graphConfig, d)))();
  const label = `${dateLabel}: ${_.map(visibleStatistics(graphConfig), labeller).join(', ')}`;

  const labelElem = xTrack.select('text');
  const txtLen = labelElem
    .text(label)
    .node()
    .getComputedTextLength();

  const maxLeft = graphConfig.scales.width - txtLen;
  const delta = maxLeft - x(d.x);
  if (delta < 0) {
    labelElem.attr('transform', translateCmd(delta, 0));
  } else {
    labelElem.attr('transform', translateCmd(0, 0));
  }
}

/** Prepare the elements necessary to draw the overlay, and set event listeners */
function prepareOverlay(projection, graphConfig) {
  const xTrack = graphConfig
    .rootElem
    .append('g')
    .attr('class', 'o-x-track__g')
    .style('display', 'none');
  xTrack
    .append('rect')
    .attr('class', 'o-x-track')
    .attr('height', graphConfig.scales.height)
    .attr('width', 0.5)
    .attr('stroke-dasharray', '5,5')
    .attr('y', 10);

  xTrack
    .append('text')
    .attr('class', 'o-x-track__title')
    .attr('y', 0)
    .append('dy', '0.35em');

  graphConfig
    .rootElem
    .append('rect')
    .attr('class', 'o-graph-overlay')
    .attr('width', graphConfig.scales.width)
    .attr('height', graphConfig.scales.height)
    .on('mouseover', () => { xTrack.style('display', null); })
    .on('mouseout', () => { xTrack.style('display', 'none'); })
    .on('mousemove', (() =>
      () => { onXTrackMouseMove(projection, graphConfig, xTrack); }
    )());
}

/** Generate a warning when there is no data to display */
function warnNoData(graphConfig) {
  const label = graphConfig.theme.label.toLocaleLowerCase();
  const location = graphConfig.location.labels.en;

  graphConfig
    .rootElem
    .append('text')
    .attr('x', 35)
    .attr('y', 50)
    .text(`Sorry, there is no ${label} data available for ${location}. Please select a different location.`)
    .attr('font-size', '15px')
    .attr('font-style', 'italic')
    .attr('fill', '#303030');
}

export default function drawGraph(projection, options) {
  let nPoints = 0;

  const graphConfig = Object.assign({}, GRAPH_OPTIONS[options.indicatorId], options);

  Object.assign(graphConfig, drawGraphRoot(graphConfig));
  graphConfig.valueRange = calculateValueRange(projection, graphConfig);
  Object.assign(graphConfig, configureAxes(graphConfig));

  drawAxes(graphConfig);
  prepareOverlay(projection, graphConfig);

  _.each(_.keys(projection), (slug, index) => {
    const series = projection[slug];

    if (series.length > 0 && isSelectedStatistic(slug, graphConfig)) {
      drawGraphLines(series, index, graphConfig);
      nPoints += series.length;
    }
  });

  if (nPoints === 0) {
    warnNoData(graphConfig);
  }
}
