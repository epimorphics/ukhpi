/* Component for rendering the map outlines as means of selecting regions */
import _ from 'lodash'
import Leaflet from 'leaflet'
import cloneLayer from 'leaflet-clonelayer'
import '../lib/leaflet-rrose'

import { findLocationNamed, findLocationById } from '../lib/locations'
import ukFeaturesData from '../data/ONS-Geographies-2020.json'

const ENGLAND = 'http://landregistry.data.gov.uk/id/region/england'

const LOCAL_AUTHORITY_TYPES = [
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/District',
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/LondonBorough',
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/MetropolitanDistrict',
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/UnitaryAuthority'
]

const COUNTY_TYPES = [
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/County',
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/GreaterLondonAuthority'
]

const REGION_TYPES = [
  'http://data.ordnancesurvey.co.uk/ontology/admingeo/EuropeanRegion'
]

/** Cases where selecting one thing highlights several things */
const LOCATION_EXPANSIONS = {
  'http://landregistry.data.gov.uk/id/region/great-britain':
      ['http://landregistry.data.gov.uk/id/region/england',
        'http://landregistry.data.gov.uk/id/region/scotland',
        'http://landregistry.data.gov.uk/id/region/wales'
      ],
  'http://landregistry.data.gov.uk/id/region/united-kingdom':
      ['http://landregistry.data.gov.uk/id/region/england',
        'http://landregistry.data.gov.uk/id/region/scotland',
        'http://landregistry.data.gov.uk/id/region/wales',
        'http://landregistry.data.gov.uk/id/region/northern-ireland'
      ],
  'http://landregistry.data.gov.uk/id/region/england-and-wales':
      ['http://landregistry.data.gov.uk/id/region/england',
        'http://landregistry.data.gov.uk/id/region/wales'
      ]
}

/** A list of reqions that are typed as metropolitan districts but which should not appear
   *  on the LA map due to problems with the data.
   */
const LA_MAP_ERRATA = [
  'http://landregistry.data.gov.uk/id/region/greater-manchester',
  'http://landregistry.data.gov.uk/id/region/west-midlands',
  'http://landregistry.data.gov.uk/id/region/west-yorkshire',
  'http://landregistry.data.gov.uk/id/region/south-yorkshire',
  'http://landregistry.data.gov.uk/id/region/merseyside',
  'http://landregistry.data.gov.uk/id/region/tyne-and-wear'
]

/* eslint-disable max-len, class-methods-use-this */
export default class LocationsMap {
  constructor (elementId) {
    this.elementId = elementId

    this.featuresIndex = {}
    this.backgroundLayer = Leaflet.layerGroup([])

    /** Guard flag so that we only initialise the features index once */
    this.featuresIndexInitialised = false

    /** The currently selected location URI, or null */
    this.currentSelection = null

    /** The root leaflet map object */
    this.leafletMap = null

    /** The currently displayed layerGroup (countries, counties, etc) */
    this.currentLayer = null

    /** Callback to notify Vue that user has selected a location via the map */
    this.onSelectionCallback = null
  }

  /** @return The location object denoted by the layer, looked up by name */
  findLayerLocation (layer) {
    const { name, code } = layer.feature.properties
    return findLocationById(code) || findLocationNamed(name)
  }

  /** @return the full list of currently selected location URIs. Non-null, but may be empty */
  currentSelections () {
    return this.currentSelection ? (LOCATION_EXPANSIONS[this.currentSelection] || [this.currentSelection]) : []
  }

  /** @return true if the layer is currently selected */
  isLayerSelected (layer) {
    return _.includes(this.currentSelections(), layer.options.ukhpiURI)
  }

  /* Layer styling */
  standardLocationStyle () {
    return {
      fillColor: '#5A8006',
      weight: 1,
      opacity: 1,
      color: 'white',
      dashArray: '3',
      fillOpacity: 0.7
    }
  }

  backgroundLocationStyle () {
    return {
      fillColor: '#5A8006',
      color: '#999999',
      weight: 1,
      dashArray: '3',
      fillOpacity: 0.7
    }
  }

  highlightLocationStyle () {
    return {
      color: '#222',
      fillColor: '#ded',
      weight: 2
    }
  }

  selectedLocationStyle (layer) {
    return _.extend(this.standardLocationStyle(layer), {
      fillColor: '#C0C006',
      color: '#686',
      fillOpacity: 0.7,
      dashArray: ''
    })
  }

  /** Apply the given style to the given layer */
  styleLayer (layer, style) {
    layer.setStyle(style(layer))
  }

  /** Work out which style to use for a layer */
  determineStyle (layer) {
    return _.bind(
      this.isLayerSelected(layer) ? this.selectedLocationStyle : this.standardLocationStyle,
      this
    )
  }

  /** Update all current layer styles */
  updateCurrentLayersStyle () {
    const determineStyle = _.bind(this.determineStyle, this)
    const styleLayer = _.bind(this.styleLayer, this)

    if (this.currentLayer) {
      this.currentLayer.eachLayer((layer) => {
        styleLayer(layer, determineStyle(layer))
      })
    }
  }

  /* Event handling and region selection */

  /** Show a popup with the location label */
  showPopup (label, point) {
    if (label) {
      const popup = new Leaflet.Rrose({
        offset: new Leaflet.Point(0, -10),
        autoPan: false
      })
        .setLatLng(point)
        .setContent(label)

      popup.openOn(this.leafletMap)
      const hidePopup = (function onHidePopup (m, p) {
        return function onClosePopup () { m.closePopup(p) }
      }(this.leafletMap, popup))

      _.delay(hidePopup, 1500)
    } else {
      this.leafletMap.closePopup()
    }
  }

  /** Highlight a feature of the map */
  onHighlightFeature (e) {
    const layer = e.target
    const locationAndType = this.findLayerLocation(layer)
    const label = locationAndType.location.labels[this.$locale]

    this.styleLayer(layer, this.highlightLocationStyle)
    this.showPopup(label, e.latlng)
  }

  /** Unhighlight a feature of the map */
  onUnhighlightFeature (e) {
    const layer = e.target
    const determineStyle = _.bind(this.determineStyle, this)
    this.styleLayer(layer, determineStyle(layer))
  }

  /** Select a feature */
  onSelectFeature (e) {
    const layer = e.target
    this.onSelectionCallback(layer.options.ukhpiURI)
  }

  /** Bind event handlers when each feature is first loaded */
  onEachFeature (feature, layer) {
    const onHighlightFeature = _.bind(this.onHighlightFeature, this)
    const onUnhighlightFeature = _.bind(this.onUnhighlightFeature, this)
    const onSelectFeature = _.bind(this.onSelectFeature, this)

    layer.on({
      mouseover: onHighlightFeature,
      mouseout: onUnhighlightFeature,
      click: onSelectFeature
    })
  }

  /* Index of features */

  /** @return An array of the index keys under which we should index this layer */
  indexKeysByLayerType (layer) {
    const partitionKeys = []
    const locationAndType = this.findLayerLocation(layer)
    const props = layer.feature.properties
    let isCountry = false

    if (props.type && props.type.match(/countries|country/)) {
      partitionKeys.push('country')
      isCountry = true
    }

    if (props.ukhpiType === 'country') {
      partitionKeys.push('country')
      isCountry = true
    }

    if (locationAndType) {
      const { location } = locationAndType
      Object.assign(layer.options, { ukhpiURI: location.uri })

      // add a partition key based on hierarchy position
      if (location.container2 === ENGLAND) {
        partitionKeys.push('county')
      }

      if (_.includes(COUNTY_TYPES, location.type)) {
        partitionKeys.push('county')
      }

      if (_.includes(REGION_TYPES, location.type) && !isCountry) {
        partitionKeys.push('region')
      }

      if (location.container3 === ENGLAND) {
        partitionKeys.push('la')
      }

      if (_.includes(LOCAL_AUTHORITY_TYPES, location.type) &&
      !_.includes(LA_MAP_ERRATA, location.uri)) {
        partitionKeys.push('la')
      }
    }

    return _.uniq(partitionKeys)
  }

  /** Update the given partition table by assigning the `layer` to the category for `key` */
  addToPartition (partitionTable, key, layer) {
    if (!_.has(partitionTable, key)) {
      const layerGroup = Leaflet.layerGroup([], { pane: 'overlayPane' })
      Object.assign(partitionTable, { [key]: layerGroup })
    }

    partitionTable[key].addLayer(layer)
  }

  /** @return the feature set from loading the given GeoJSON structure */
  loadGeoJson (json) {
    const onEachFeature = _.bind(this.onEachFeature, this)
    return Leaflet.geoJson(json, {
      style: this.standardLocationStyle,
      onEachFeature
    })
  }

  /** Update the index of GB and NI GeoJSON features */
  indexFeatures () {
    const gbFeatures = this.loadGeoJson(ukFeaturesData)
    const { featuresIndex, backgroundLayer, addToPartition } = this

    _.each([gbFeatures], (features) => {
      features.eachLayer((layer) => {
        _.each(this.indexKeysByLayerType(layer), (indexKey) => {
          addToPartition(featuresIndex, indexKey, layer)

          // if this is a country, we also use it to build the background layer
          if (indexKey === 'country') {
            const bgLayer = cloneLayer(layer)
            bgLayer.options.pane = 'tilePane'
            backgroundLayer.addLayer(bgLayer)
          }
        })
      })
    })
  }

  /** @return The indexed collection of Leaflet layers, ensuring it is only initialised once */
  indexedFeatures () {
    if (!this.featuresIndexInitialised) {
      this.indexFeatures()
      this.featuresIndexInitialised = true
    }

    return this.featuresIndex
  }

  /** Reset any selections back to empty */
  resetSelection () {
    this.currentSelection = null
  }

  /** @return The Leaflet map object, creating a new one if necessary */
  createMap () {
    if (!this.leafletMap) {
      this.indexedFeatures()

      this.leafletMap = Leaflet.map(this.elementId, {
        zoomDelta: 0.5,
        zoomSnap: 0
      })
        .setView([55.7, -2], 4.7)
      this.leafletMap
        .attributionControl
        .setPrefix(`Open Government License &copy; Crown copyright ${new Date().getFullYear()}`)
      this.leafletMap
        .addLayer(this.backgroundLayer, { pane: 'tilePane' })

      const { styleLayer, backgroundLocationStyle } = this
      this.backgroundLayer.eachLayer((layer) => { styleLayer(layer, backgroundLocationStyle) })
    }

    return this.leafletMap
  }

  /** @return The Leaflet map object, ensuring that it is reset */
  getMap () {
    const map = this.createMap(this.elementId)
    this.resetSelection()
    return map
  }

  /** Remove the given feature group from the map */
  removeLayer (layer, map) {
    if (layer) {
      map.removeLayer(layer)
      map.closePopup()
    }
  }

  /** Show the given feature group on the map */
  showFeatureGroup (groupId, map) {
    this.currentLayer = this.indexedFeatures()[groupId]
    map.addLayer(this.currentLayer)
  }

  /** Display the map and optionally a feature group */
  showMap (featureGroupId, selectionCallback) {
    const map = this.getMap()
    this.onSelectionCallback = selectionCallback

    if (featureGroupId) {
      this.removeLayer(this.currentLayer, map)
      this.showFeatureGroup(featureGroupId, map)
    }
  }

  /** Nominate a new location to be the currently selected location */
  setSelectedLocationMap (location) {
    this.currentSelection = location.uri
    this.updateCurrentLayersStyle()
  }
}
