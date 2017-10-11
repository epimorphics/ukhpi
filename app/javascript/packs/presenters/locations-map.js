/* Component for rendering the map outlines as means of selecting regions */
import _ from 'lodash';
import Leaflet from 'leaflet';
import cloneLayer from 'leaflet-clonelayer';

import { findLocationNamed, findLocationById } from '../lib/locations';
// import gbFeaturesData from '../data/great-britain-geo.json';
// import niFeaturesData from '../data/northern-ireland-geo.json';
import ukFeaturesData from '../data/uk-geo.json';

const DEFAULT_LAYER = 'country';

const ENGLAND = 'http://landregistry.data.gov.uk/id/region/england';

const LOCAL_AUTHORITY_TYPES = [
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/District',
  // "http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough",
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/LondonBorough',
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/MetropolitanDistrict',
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/UnitaryAuthority',
];

const COUNTY_TYPES = [
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/County',
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/GreaterLondonAuthority',
];

const REGION_TYPES = [
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/EuropeanRegion',
];

  /** Cases where selecting one thing highlights several things */
const LOCATION_EXPANSIONS = {
  'http://landregistry.data.gov.uk/id/region/great-britain':
      ['http://landregistry.data.gov.uk/id/region/england',
        'http://landregistry.data.gov.uk/id/region/scotland',
        'http://landregistry.data.gov.uk/id/region/wales',
      ],
  'http://landregistry.data.gov.uk/id/region/united-kingdom':
      ['http://landregistry.data.gov.uk/id/region/england',
        'http://landregistry.data.gov.uk/id/region/scotland',
        'http://landregistry.data.gov.uk/id/region/wales',
        'http://landregistry.data.gov.uk/id/region/northern-ireland',
      ],
  'http://landregistry.data.gov.uk/id/region/england-and-wales':
      ['http://landregistry.data.gov.uk/id/region/england',
        'http://landregistry.data.gov.uk/id/region/wales',
      ],
};

  /** A list of reqions that are typed as metropolitan districts but which should not appear
   *  on the LA map due to problems with the data.
   */
const LA_MAP_ERRATA = [
  'http://landregistry.data.gov.uk/id/region/greater-manchester',
  'http://landregistry.data.gov.uk/id/region/west-midlands',
  'http://landregistry.data.gov.uk/id/region/west-yorkshire',
  'http://landregistry.data.gov.uk/id/region/south-yorkshire',
  'http://landregistry.data.gov.uk/id/region/merseyside',
  'http://landregistry.data.gov.uk/id/region/tyne-and-wear',
];

const featuresIndex = {};
const backgroundLayer = Leaflet.layerGroup([]);


/* Module variables */

/** Guard flag so that we only initialise the features index once */
let featuresIndexInitialised = false;

/** The currently selected location URI, or null */
let currentSelection = null;

/** The root leaflet map object */
let leafletMap = null;

/** The currently displayed layerGroup (countries, counties, etc) */
let currentLayer = null;

/** Callback to notify Vue that user has selected a location via the map */
let onSelectionCallback = null;

/* Utilities */

/** @return The location object denoted by the layer, looked up by name */
function findLayerLocation(layer) {
  const { name, ukhpiID } = layer.feature.properties;
  const location = name ? findLocationNamed(name) : findLocationById(ukhpiID);

  if (location) {
    return location;
  }

  console.log(`Could not find location named ${name}`);
  return null;
}

/** @return the full list of currently selected location URIs. Non-null, but may be empty */
function currentSelections() {
  return currentSelection ? (LOCATION_EXPANSIONS[currentSelection] || [currentSelection]) : [];
}

/** @return true if the layer is currently selected */
function isLayerSelected(layer) {
  return _.includes(currentSelections(), layer.options.ukhpiURI);
}

/* Layer styling */
function standardLocationStyle() {
  return {
    fillColor: '#5A8006',
    weight: 1,
    opacity: 1,
    color: 'white',
    dashArray: '3',
    fillOpacity: 0.7,
  };
}

function backgroundLocationStyle() {
  return {
    fillColor: '#999999',
    color: '#999999',
    weight: 1,
    dashArray: '3',
    fillOpacity: 0.7,
  };
}

function highlightLocationStyle() {
  return {
    color: '#222',
    fillColor: '#ded',
    weight: 2,
  };
}

function selectedLocationStyle(layer) {
  return _.extend(standardLocationStyle(layer), {
    fillColor: '#C0C006',
    color: '#686',
    fillOpacity: 0.7,
    dashArray: '',
  });
}

/** Apply the given style to the given layer */
function styleLayer(layer, style) {
  layer.setStyle(style(layer));
}

/** Work out which style to use for a layer */
function determineStyle(layer) {
  return (isLayerSelected(layer)) ? selectedLocationStyle : standardLocationStyle;
}

/** Update all current layer styles */
function updateCurrentLayersStyle() {
  if (currentLayer) {
    currentLayer.eachLayer((layer) => {
      styleLayer(layer, determineStyle(layer));
    });
  }
}

/* Event handling and region selection */

/** Show a popup with the location label */
function showPopup(label, point) {
  if (label) {
    const popup = Leaflet.popup({
      offset: new Leaflet.Point(0, -10),
      autoPan: false,
    })
      .setLatLng(point)
      .setContent(label);

    popup.openOn(leafletMap);
    const hidePopup = (function onHidePopup(m, p) {
      return function onClosePopup() { m.closePopup(p); };
    }(leafletMap, popup));

    _.delay(hidePopup, 2000);
  } else {
    leafletMap.closePopup();
  }
}

/** Highlight a feature of the map */
function onHighlightFeature(e) {
  const layer = e.target;
  const locationAndType = findLayerLocation(layer);
  const label = locationAndType.location.labels.en;

  styleLayer(layer, highlightLocationStyle);
  showPopup(label, e.latlng);
}

/** Unhighlight a feature of the map */
function onUnhighlightFeature(e) {
  const layer = e.target;
  styleLayer(layer, determineStyle(layer));
}

/** Select a feature */
function onSelectFeature(e) {
  const layer = e.target;
  onSelectionCallback(layer.options.ukhpiURI);
}

/** Bind event handlers when each feature is first loaded */
function onEachFeature(feature, layer) {
  layer.on({
    mouseover: onHighlightFeature,
    mouseout: onUnhighlightFeature,
    click: onSelectFeature,
  });
}

/* Index of features */

/** @return An array of the index keys under which we should index this layer */
function indexKeysByLayerType(layer) {
  const partitionKeys = [];
  const locationAndType = findLayerLocation(layer);
  const props = layer.feature.properties;
  let isCountry = false;

  if (props.type && props.type.match(/countries|country/)) {
    partitionKeys.push('country');
    isCountry = true;
  }

  if (props.ukhpiType === 'country') {
    partitionKeys.push('country');
    isCountry = true;
  }

  if (locationAndType) {
    const { location } = locationAndType;
    Object.assign(layer.options, { ukhpiURI: location.uri });

    // add a partition key based on hierarchy position
    if (location.container2 === ENGLAND) {
      partitionKeys.push('county');
    }

    if (_.includes(COUNTY_TYPES, location.type)) {
      partitionKeys.push('county');
    }

    if (_.includes(REGION_TYPES, location.type) && !isCountry) {
      partitionKeys.push('region');
    }

    if (location.container3 === ENGLAND) {
      partitionKeys.push('la');
    }

    if (_.includes(LOCAL_AUTHORITY_TYPES, location.type) &&
      !_.includes(LA_MAP_ERRATA, location.uri)) {
      partitionKeys.push('la');
    }
  }

  return _.uniq(partitionKeys);
}

/** Update the given partition table by assigning the `layer` to the category for `key` */
function addToPartition(partitionTable, key, layer) {
  if (!_.has(partitionTable, key)) {
    const layerGroup = Leaflet.layerGroup([], { pane: 'overlayPane' });
    Object.assign(partitionTable, { [key]: layerGroup });
  }

  partitionTable[key].addLayer(layer);
}

/** @return the feature set from loading the given GeoJSON structure */
function loadGeoJson(json) {
  return Leaflet.geoJson(json, { style: standardLocationStyle, onEachFeature });
}

/** Update the index of GB and NI GeoJSON features */
function indexFeatures() {
  // const gbFeatures = loadGeoJson(gbFeaturesData);
  // const niFeatures = loadGeoJson(niFeaturesData);
  const ukFeatures = loadGeoJson(ukFeaturesData);

  _.each([ukFeatures], (features) => {
    features.eachLayer((layer) => {
      _.each(indexKeysByLayerType(layer), (indexKey) => {
        addToPartition(featuresIndex, indexKey, layer);

        // if this is a country, we also use it to build the background layer
        if (indexKey === 'country') {
          const bgLayer = cloneLayer(layer);
          bgLayer.options.pane = 'tilePane';
          backgroundLayer.addLayer(bgLayer);
        }
      });
    });
  });
}

/** @return The indexed collection of Leaflet layers, ensuring it is only initialised once */
function indexedFeatures() {
  if (!featuresIndexInitialised) {
    indexFeatures();
    featuresIndexInitialised = true;
  }

  return featuresIndex;
}

/** Reset any selections back to empty */
function resetSelection() {
  // const cs = currentSelections; TODO
  currentSelection = null;
  // unHighlightFeature(cs); TODO
}

/** @return The Leaflet map object, creating a new one if necessary */
function createMap(elementId = 'map') {
  if (!leafletMap) {
    indexedFeatures();

    leafletMap = Leaflet.map(elementId)
      .setView([54.6, -2], 5);
    leafletMap
      .attributionControl
      .setPrefix(`Open Government License &copy; Crown copyright ${new Date().getFullYear()}`);
    leafletMap
      .addLayer(backgroundLayer, { pane: 'tilePane' });
    backgroundLayer.eachLayer((layer) => { styleLayer(layer, backgroundLocationStyle); });
  }

  return leafletMap;
}

/** @return The Leaflet map object, ensuring that it is reset */
function getMap(elementId = 'map') {
  const map = createMap(elementId);
  resetSelection();
  return map;
}

/** Remove the given feature group from the map */
function removeLayer(layer, map) {
  if (layer) {
    map.removeLayer(layer);
    map.closePopup();
  }
}

/** Show the given feature group on the map */
function showFeatureGroup(groupId, map) {
  currentLayer = indexedFeatures()[groupId];
  map.addLayer(currentLayer);
}

/** Display the map and optionally a feature group */
export function showMap(elementId, featureGroupId, selectionCallback) {
  const map = getMap(elementId);
  onSelectionCallback = selectionCallback;

  if (featureGroupId) {
    removeLayer(currentLayer, map);
    showFeatureGroup(featureGroupId, map);
  }
}

/** Nominate a new location to be the currently selected location */
export function setSelectedLocationMap(location) {
  console.log('Setting selected location URI to ', location.uri);
  currentSelection = location.uri;
  updateCurrentLayersStyle();
}

/*
///////////////////////////////////////

function showLocationSelection(selectionType) {
  $('.c-location-search').addClass('hidden');
  $(`.c-location-search.${selectionType}`).removeClass('hidden');
}


// feature selection

function findLayer(id) {
  let found = null;
  _.each(this._featuresPartition, (featureGroup) => {
    featureGroup.eachLayer((layer) => {
      const uri = _.get(layer, 'feature.properties.ukhpiURI');
      found = (id === uri) ? layer : found;
    });
  });

  return found;
}


function unHighlightFeatures(featureNames) {
  const mv = this;
  _.each(featureNames, function (featureName) {
    this.styleLayerNamed(featureName, mv.styleFor(featureName));
  });
}

function styleFor(layerName) {
  return _.includes(this._currentSelections, layerName) ? selectedLocationStyle : defaultLocationStyle;
}

function styleLayerNamed(layerName, style) {
  const layer = this.findLayer(layerName);

  if (layer) {
    this.styleLayer(layer, style);
  } else {
    Log.warn(`No layer for: ${layerName}`);
  }
}

function styleLayer(layer, style) {
  layer.setStyle(style(layer));
}

function showSelectedLocations(locations) {
  const sln = _.bind(this.styleLayerNamed, this);

  if (this._currentSelections) {
    _.each(this._currentSelections, (selectedLayer) => {
      sln(selectedLayer, defaultLocationStyle);
    });
    this._currentSelections = [];
  }

  _.each(locations, (layer) => {
    sln(layer, selectedLocationStyle);
  });

  this._currentSelections = locations;
}

function setDefaultLocation(uri) {
  this._defaultLocation = uri;
}

function onShowTab(e) {
  const target = $(e.target).attr('href');
  if (target === '#location') {
    this.show(true);
  }
}

function onRevealPreferences() {
  this.show(true);
}

function onChangeLocationType(e, args) {
  this.showLocationSelection(args.locationType);
  _.defer(_.bind(this.showLayer, this), args.locationType, this._map);
}

function onSelectLocation(e, uri) {
  const selected = LOCATION_EXPANSIONS[uri] || [uri];
  this.showSelectedLocations(selected);
}


function onSelectFeature(l) {
  const feature = l.target && l.target.feature;
  if (feature) {
    const uri = feature.properties.ukhpiURI;
    $('body').trigger(Constants.EVENT_SELECTED_MAP, uri);
  }
}
*/
