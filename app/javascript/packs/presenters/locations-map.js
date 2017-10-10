/* Component for rendering the map outlines as means of selecting regions */
import _ from 'lodash';
import Leaflet from 'leaflet';

import { findLocationNamed } from '../lib/locations';
import gbFeaturesData from '../data/great-britain-geo.json';
import niFeaturesData from '../data/northern-ireland-geo.json';

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

/* Layer styling */

function standardRegionStyle() {
  return {
    fillColor: '#5A8006',
    weight: 1,
    opacity: 1,
    color: 'white',
    dashArray: '3',
    fillOpacity: 0.7,
  };
}

function backgroundRegionStyle() {
  return {
    fillColor: '#666666',
    color: '#666666',
    weight: 1,
    dashArray: '3',
    fillOpacity: 0.7,
  };
}

function highlightRegionStyle() {
  return {
    color: '#222',
    fillColor: '#ded',
    weight: 2,
  };
}

function isBackgroundLayer(layer) {
  return layer && _.get(layer, 'feature.properties.ISO') === 'GBR';
}

function defaultRegionStyle(layer) {
  return (isBackgroundLayer(layer) ? backgroundRegionStyle : standardRegionStyle)(layer);
}

function selectedRegionStyle(layer) {
  return _.extend(defaultRegionStyle(layer), {
    fillColor: '#C0C006',
    color: '#686',
    fillOpacity: 0.7,
    dashArray: '',
  });
}

/* Index of features */

/** @return The location object denoted by the layer, looked up by name */
function findLayerLocation(layer) {
  const { name } = layer.feature.properties;
  const location = findLocationNamed(name);

  if (location) {
    return location.uri;
  }

  console.log(`Could not find location named ${name}`);
  return null;
}

/** @return An array of the index keys under which we should index this layer */
function indexKeysByLayerType(layer) {
  const partitionKeys = [];
  const location = findLayerLocation(layer);

  if (layer.feature.properties.type.match(/countries|country/)) {
    partitionKeys.push('country');
  }

  if (location) {
    // add a partition key based on hierarchy position
    if (location.container2 === ENGLAND) {
      partitionKeys.push('county');
    }

    if (_.includes(COUNTY_TYPES, location.type)) {
      partitionKeys.push('county');
    }

    if (_.includes(REGION_TYPES, location.type)) {
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
    Object.assign(partitionTable, { [key]: Leaflet.layerGroup([]) });
  }

  partitionTable[key].addLayer(layer);
}

/** @return the feature set from loading the given GeoJSON structure */
function loadGeoJson(json) {
  return Leaflet.geoJson(json, { style: defaultRegionStyle /* , onEachFeature */ });
}

/** Update the index of GB and NI GeoJSON features */
function indexFeatures() {
  const gbFeatures = loadGeoJson(gbFeaturesData);
  const niFeatures = loadGeoJson(niFeaturesData);

  _.each([gbFeatures, niFeatures], (features) => {
    features.eachLayer((layer) => {
      _.each(indexKeysByLayerType(layer), (indexKey) => {
        addToPartition(featuresIndex, indexKey, layer);
      });
    });
  });
}

let featuresIndexInitialised = false;

/** @return The indexed collection of Leaflet layers, ensuring it is only initialised once */
function indexedFeatures() {
  if (!featuresIndexInitialised) {
    indexFeatures();
    featuresIndexInitialised = true;
  }

  return featuresIndex;
}

let currentSelections = [];

/** Reset any selections back to empty */
function resetSelection() {
  // const cs = currentSelections; TODO
  currentSelections = [];
  // unHighlightFeature(cs); TODO
}

let leafletMap = null;

/** @return The Leaflet map object, creating a new one if necessary */
function createMap(elementId = 'map') {
  if (!leafletMap) {
    leafletMap = Leaflet.map(elementId)
      .setView([54.0072, -2], 5);
    leafletMap
      .attributionControl
      .setPrefix(`Open Government License &copy; Crown copyright ${new Date().getFullYear()}`);
  }

  return leafletMap;
}

/** @return The Leaflet map object, ensuring that it is reset */
function getMap(elementId = 'map') {
  const map = createMap(elementId);
  resetSelection();
  return map;
}

let currentLayer = null;

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
export function showMap(elementId, featureGroupId) {
  const map = getMap(elementId);

  if (featureGroupId) {
    removeLayer(currentLayer, map)
    showFeatureGroup(featureGroupId, map);
  }
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
  return _.includes(this._currentSelections, layerName) ? selectedRegionStyle : defaultRegionStyle;
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
      sln(selectedLayer, defaultRegionStyle);
    });
    this._currentSelections = [];
  }

  _.each(locations, (layer) => {
    sln(layer, selectedRegionStyle);
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

function onEachFeature(feature, layer) {
  layer.on({
    mouseover: _.bind(this.onHighlightFeature, this),
    mouseout: _.bind(this.onUnhighlightFeature, this),
    click: _.bind(this.onSelectFeature, this),
  });
}

function onHighlightFeature(e) {
  const layer = e.target;
  const feature = layer.feature;

  this.styleLayer(layer, highlightRegionStyle);
  this.showPopup(_.get(feature, 'properties.ukhpiLabel'), e.latlng);
}

function showPopup(label, point) {
  if (label) {
    const popup = Leaflet.popup({
      offset: new Leaflet.Point(0, -10),
      autoPan: false,
    })
      .setLatLng(point)
      .setContent(label);

    popup.openOn(this._map);
    const hidePopup = (function (m, p) {
      return function () { m.closePopup(p); };
    }(this._map, popup));

    _.delay(hidePopup, 2000);
  } else {
    this._map.closePopup();
  }
}

function onUnhighlightFeature(e) {
  const layer = e.target;
  const uri = layer.feature.properties.ukhpiURI;
  const style = this.styleFor(uri);
  this.styleLayer(layer, style);
}

function onSelectFeature(l) {
  const feature = l.target && l.target.feature;
  if (feature) {
    const uri = feature.properties.ukhpiURI;
    $('body').trigger(Constants.EVENT_SELECTED_MAP, uri);
  }
}
*/
