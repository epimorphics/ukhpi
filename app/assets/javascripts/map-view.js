/* Component for rendering the map outlines as means of selecting regions */
/* eslint-disable */
modulejs.define( "map-view", [
  "lib/lodash",
  "lib/jquery",
  "lib/leaflet",
  "lib/js-logger",
  "constants",
  "routes",
  "regions-table"
],
function(
  _,
  $,
  Leaflet,
  Log,
  Constants,
  Routes,
  Regions
) {
  "use strict";

  var MapView = function() {
    this.fetchFeatures();
    this.bindEvents();
  };

  var DEFAULT_LAYER = "country";

  var ENGLAND = "http://landregistry.data.gov.uk/id/region/england";

  var LOCAL_AUTHORITY_TYPES = [
    "http://data.ordnancesurvey.co.uk/ontology/admingeo/District",
    // "http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough",
    "http://data.ordnancesurvey.co.uk/ontology/admingeo/LondonBorough",
    "http://data.ordnancesurvey.co.uk/ontology/admingeo/MetropolitanDistrict",
    "http://data.ordnancesurvey.co.uk/ontology/admingeo/UnitaryAuthority"
  ];

  var COUNTY_TYPES = [
    "http://data.ordnancesurvey.co.uk/ontology/admingeo/County",
    "http://data.ordnancesurvey.co.uk/ontology/admingeo/GreaterLondonAuthority"
  ];

  var REGION_TYPES = [
    "http://data.ordnancesurvey.co.uk/ontology/admingeo/EuropeanRegion"
  ];

  /** Cases where selecting one thing highlights several things */
  var LOCATION_EXPANSIONS = {
    "http://landregistry.data.gov.uk/id/region/great-britain":
      ["http://landregistry.data.gov.uk/id/region/england",
       "http://landregistry.data.gov.uk/id/region/scotland",
       "http://landregistry.data.gov.uk/id/region/wales"
      ],
    "http://landregistry.data.gov.uk/id/region/united-kingdom":
      ["http://landregistry.data.gov.uk/id/region/england",
       "http://landregistry.data.gov.uk/id/region/scotland",
       "http://landregistry.data.gov.uk/id/region/wales",
       "http://landregistry.data.gov.uk/id/region/northern-ireland"
      ],
    "http://landregistry.data.gov.uk/id/region/england-and-wales":
      ["http://landregistry.data.gov.uk/id/region/england",
       "http://landregistry.data.gov.uk/id/region/wales"
      ]
  };

  /** A list of reqions that are typed as metropolitan districts but which should not appear
   *  on the LA map due to problems with the data.
   */
  var LA_MAP_ERRATA = [
    "http://landregistry.data.gov.uk/id/region/greater-manchester",
    "http://landregistry.data.gov.uk/id/region/west-midlands",
    "http://landregistry.data.gov.uk/id/region/west-yorkshire",
    "http://landregistry.data.gov.uk/id/region/south-yorkshire",
    "http://landregistry.data.gov.uk/id/region/merseyside",
    "http://landregistry.data.gov.uk/id/region/tyne-and-wear"
  ];

  _.extend( MapView.prototype, {
    bindEvents: function() {
      $("a[data-toggle='tab']").on( "shown.bs.tab", _.bind( this.onShowTab, this ) );
      $("body").on( Constants.EVENT_PREFS_REVEALED, _.bind( this.onRevealPreferences, this ) );
      $("body")
        .on( Constants.EVENT_LOCATION_TYPE_CHANGE, _.bind( this.onChangeLocationType, this ) )
        .on( Constants.EVENT_LOCATION_SELECTED, _.bind( this.onSelectLocation, this ) );
    },

    fetchFeatures: function() {
      this._outstandingRequests = 2;

      $.getJSON( Routes.publicPath + "features.json" )
       .done( _.bind( this.onFeaturesLoaded, this ) )
       .error( function( e, m ) {
          Log.warn( "Failed to retrieve map features: " + m + ", " + e );
       } );
      $.getJSON( Routes.publicPath + "uk.json" )
       .done( _.bind( this.onUkFeatureLoaded, this ) );
    },

    onFeaturesLoaded: function( json ) {
      var features = Leaflet.geoJson( json, {style: defaultRegionStyle, onEachFeature: _.bind( this.onEachFeature, this )} );
      this._featuresPartition = this.partitionFeatures( features );
      this.receivedRequest();
    },

    onUkFeatureLoaded: function( json ) {
      this._ukFeature = Leaflet.geoJson( json, {style: backgroundRegionStyle} );
      this.receivedRequest();
    },

    receivedRequest: function() {
      this._outstandingRequests--;
      if (this._outstandingRequests === 0) {
        this.show( false );
      }
    },

    show: function( create ) {
      if (!this._map && create) {
        this.createMap();
      }
      if (this._map && !this._map.hasLayer( this._ukFeature )) {
        this._map.addLayer( this._ukFeature );
        this.showLayer( DEFAULT_LAYER, this._map );
      }

      if (this._map && this._defaultLocation) {
        this.onSelectLocation( null, this._defaultLocation );
        this._defaultLocation = null;
      }
    },

    showLayer: function( layerId, map ) {
      if (this._currentLayer) {
        map.removeLayer( this._currentLayer );
        map.closePopup();
      }
      this._currentLayer = this._featuresPartition[layerId];
      map.addLayer( this._currentLayer );
    },

    showLocationSelection: function( selectionType ) {
      $(".c-location-search").addClass( "hidden" );
      $(".c-location-search." + selectionType ).removeClass( "hidden" );
    },

    partitionFeatures: function( features ) {
      var featuresPartition = {};

      features.eachLayer( function( layer ) {
        _.each( partitionKeysByType( layer ), function( partKey ) {
          addToPartition( featuresPartition, partKey, layer );
        } );
      } );

      return featuresPartition;
    },

    createMap: function() {
      if (!this._map) {
        this._map = Leaflet.map( "map" )
                           .setView( [54.0072, -2], 5 );
        this._map.attributionControl.setPrefix( "Open Government License &copy; Crown copyright 2016" );
      }
      else {
        this.resetSelection();
      }

      return this._map;
    },

    // feature selection

    findLayer: function( id ) {
      var found = null;
      _.each( this._featuresPartition, function( featureGroup ) {
        featureGroup.eachLayer( function( layer ) {
          var uri = _.get( layer, "feature.properties.ukhpiURI" );
          found = (id === uri) ? layer : found;
        } );

      } );

      return found;
    },

    resetSelection: function() {
      var cs = this._currentSelections;
      this._currentSelections = [];
      this.unHighlightFeature( cs );
    },

    unHighlightFeatures: function( featureNames ) {
      var mv = this;
      _.each( featureNames, function( featureName ) {
        this.styleLayerNamed( featureName, mv.styleFor( featureName ) );
      } );
    },

    styleFor: function( layerName ) {
      return _.includes( this._currentSelections, layerName ) ? selectedRegionStyle : defaultRegionStyle;
    },

    styleLayerNamed: function( layerName, style ) {
      var layer = this.findLayer( layerName );

      if (layer) {
        this.styleLayer( layer, style );
      }
      else {
        Log.warn( "No layer for: " + layerName );
      }
    },

    styleLayer: function( layer, style ) {
      layer.setStyle( style( layer ) );
    },

    showSelectedLocations: function( locations ) {
      var sln = _.bind( this.styleLayerNamed, this );

      if (this._currentSelections) {
        _.each( this._currentSelections, function( selectedLayer ) {
          sln( selectedLayer, defaultRegionStyle );
        } );
        this._currentSelections = [];
      }

      _.each( locations, function( layer ) {
        sln( layer, selectedRegionStyle );
      } );

      this._currentSelections = locations;
    },

    setDefaultLocation: function( uri ) {
      this._defaultLocation = uri;
    },

    onShowTab: function( e ) {
      var target = $(e.target).attr( "href" );
      if (target === "#location") {
        this.show( true );
      }
    },

    onRevealPreferences: function() {
      this.show( true );
    },

    onChangeLocationType: function( e, args ) {
      this.showLocationSelection( args.locationType );
      _.defer( _.bind( this.showLayer, this ), args.locationType, this._map );
    },

    onSelectLocation: function( e, uri ) {
      var selected = LOCATION_EXPANSIONS[uri] || [uri];
      this.showSelectedLocations( selected );
    },

    onEachFeature: function( feature, layer ) {
      layer.on({
          mouseover: _.bind( this.onHighlightFeature, this ),
          mouseout: _.bind( this.onUnhighlightFeature, this ),
          click: _.bind( this.onSelectFeature, this )
      });
    },

    onHighlightFeature: function( e ) {
      var layer = e.target;
      var feature = layer.feature;

      this.styleLayer( layer, highlightRegionStyle );
      this.showPopup( _.get( feature, "properties.ukhpiLabel" ), e.latlng );
    },

    showPopup: function( label, point ) {
      if (label) {
        var popup = Leaflet.popup( {
          offset: new Leaflet.Point( 0, -10 ),
          autoPan: false
        } )
          .setLatLng( point )
          .setContent( label );

        popup.openOn( this._map );
        var hidePopup = (function( m, p ) {
          return function() {m.closePopup( p );};
        })( this._map, popup );

        _.delay( hidePopup, 2000 );
      }
      else {
        this._map.closePopup();
      }
    },

    onUnhighlightFeature: function( e ) {
      var layer = e.target;
      var uri = layer.feature.properties.ukhpiURI;
      var style = this.styleFor( uri );
      this.styleLayer( layer, style );
    },

    onSelectFeature: function( l ) {
      var feature = l.target && l.target.feature;
      if (feature) {
        var uri = feature.properties.ukhpiURI;
        $("body").trigger( Constants.EVENT_SELECTED_MAP, uri );
      }
    }

  } );


  var isBackgroundLayer = function( layer ) {
    return layer && _.get( layer, "feature.properties.ISO" ) === "GBR";
  };

  var defaultRegionStyle = function( layer ) {
    return (isBackgroundLayer( layer ) ? backgroundRegionStyle : standardRegionStyle)( layer );
  };

  var standardRegionStyle = function() {
    return {
      fillColor: "#5A8006",
      weight: 1,
      opacity: 1,
      color: "white",
      dashArray: "3",
      fillOpacity: 0.7
    };
  };

  var backgroundRegionStyle = function() {
    return {
      fillColor: "#666666",
      color: "#666666",
      weight: 1,
      dashArray: "3",
      fillOpacity: 0.7
    };
  };

  var selectedRegionStyle = function( layer ) {
    return _.extend( defaultRegionStyle( layer ), {
      fillColor: "#C0C006",
      color: "#686",
      fillOpacity: 0.7,
      dashArray: ""
    } );
  };

  var highlightRegionStyle = function() {
    return {
      color: "#222",
      fillColor: "#ded",
      weight: 2
    };
  };

  /** @return The URI of the layer, looked up either by GSS code or name */
  var regionURI = function( layer ) {
    var id = layer.feature.properties.ukhpiID;
    var uri = Regions.gssIndex[id];

    if (!uri) {
      var lName = _.find( Regions.locationNames, function( locName ) {
        return locName.label === id;
      } );

      uri = lName ? lName.value : uri;
    }

    return uri;
  };

  var partitionKeysByType = function( layer ) {
    var partitionKeys = [];

    // workaround to present a natural category of "country" to users
    if (layer.feature.properties.ukhpiType === "country") {
      partitionKeys.push( "country" );
    }
    else {
      var layerRegionURI = regionURI( layer );
      var region = Regions.locations[layerRegionURI];

      // add a partition key based on hierarchy position
      if (region.container2 === ENGLAND) {
        partitionKeys.push( "county" );
      }

      if (region.container3 === ENGLAND) {
        partitionKeys.push( "local-authority" );
      }

      if (_.includes( REGION_TYPES, region.type )) {
        partitionKeys.push( "region");
      }

      if (_.includes( COUNTY_TYPES, region.type )) {
        partitionKeys.push( "county" );
      }

      if (_.includes( LOCAL_AUTHORITY_TYPES, region.type ) &&
          !_.includes( LA_MAP_ERRATA, layerRegionURI )) {
        partitionKeys.push( "local-authority");
      }
    }

    return _.uniq( partitionKeys );
  };

  var addToPartition = function( partitionTable, key, layer ) {
    if (!_.has( partitionTable, key )) {
      partitionTable[key] = Leaflet.layerGroup( [] );
    }

    partitionTable[key].addLayer( layer );
  };


  return MapView;
} );
