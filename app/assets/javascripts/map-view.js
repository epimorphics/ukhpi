/* Component for rendering the map outlines as means of selecting regions */

modulejs.define( "map-view", [
  "lib/lodash",
  "lib/jquery",
  "lib/leaflet",
  "routes",
  "regions-table"
],
function(
  _,
  $,
  Leaflet,
  Routes,
  Regions
) {
  "use strict";

  var MapView = function() {
    this.fetchFeatures();
    this.bindEvents();
  };

  var DEFAULT_LAYER = "country";

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

  _.extend( MapView.prototype, {
    bindEvents: function() {
      $("a[data-toggle='tab']").on( "shown.bs.tab", _.bind( this.onShowTab, this ) );
      $("body").on( "ukhpi.prefs.revealed", _.bind( this.onRevealPreferences, this ) );
      $("body")
        .on( "ukhpi.location-type.change", _.bind( this.onChangeLocationType, this ) )
        .on( "ukhpi.location.selected", _.bind( this.onSelectLocation, this ) );
    },

    fetchFeatures: function() {
      this._outstandingRequests = 2;

      $.getJSON( Routes.public_path + "features.json" )
       .done( _.bind( this.onFeaturesLoaded, this ) )
       .error( function( e, m, a ) {
          console.log( "API get failed: " );
          console.log( e );
          console.log( m );
          console.log( a );
       } );
      $.getJSON( Routes.public_path + "uk.json" )
       .done( _.bind( this.onUkFeatureLoaded, this ) );
    },

    onFeaturesLoaded: function( json ) {
      var features = Leaflet.geoJson( json, {style: defaultRegionStyle, onEachFeature: _.bind( this.onEachFeature, this )} );
      this._featuresPartition = this.partitionFeatures( features );
      this.receivedRequest();
    },

    onUkFeatureLoaded: function( json ) {
      this._ukFeature = Leaflet.geoJson( json, {style: backgroundRegionStyle, onEachFeature: _.bind( this.onEachFeature, this )} );
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
        this._map.attributionControl.setPrefix( "Contains OGL and Ordnance Survey data &copy; Crown copyright 2016" );
      }
      else {
        this.resetSelection();
      }

      return this._map;
    },

    // feature selection

    findLayer: function( id ) {
      var found = null;
      this._map.eachLayer( function( layer ) {
        var uri = _.get( layer, "feature.properties.ukhpiURI" );
        found = (id === uri) ? layer : found;
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
        console.log("No layer for: " + layerName );
      }
    },

    styleLayer: function( layer, style ) {
      layer.setStyle( style() );
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

      if (feature && feature.properties && feature.properties.ukhpiLabel) {
        Leaflet.popup( {
            offset: new Leaflet.Point( 0, -10 ),
            autoPan: false
          } )
         .setLatLng( e.latlng )
         .setContent( feature.properties.ukhpiLabel )
         .openOn( this._map );
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
        $("body").trigger( "ukhpi.location.selected-map", uri );
      }
    }

  } );


  var defaultRegionStyle = function() {
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
    return _.extend( defaultRegionStyle(), {
      fillColor: "#666666",
      color: "#666666",
      fillOpacity: 0.7
    } );
  };

  var selectedRegionStyle = function() {
    return _.extend( defaultRegionStyle(), {
      fillColor: "#C0C006",
      color: "#686",
      fillOpacity: 0.7,
      dashArray: ""
    } );
  };

  var highlightRegionStyle = function() {
    return _.extend( defaultRegionStyle(), {
      color: "ff0"
    } );
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

  var layerType = function( layer ) {
    var rURI = regionURI( layer );
    return rURI ? Regions.locations[rURI].type : "unknown";
  };

  var partitionKeysByType = function( layer ) {
    // workaround to present a natural category of "country" to users
    if (layer.feature.properties.ukhpiType === "country") {
      return countryPartitionKeys( layer );
    }
    else {
      return {
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/Borough": ["local-authority"],
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/County": ["county"],
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/District": ["local-authority"],
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/EuropeanRegion": ["region"],
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/GreaterLondonAuthority": ["county"],
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/LondonBorough": ["local-authority"],
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/MetropolitanDistrict": ["local-authority"],
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/No_Region_type": [],
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/UnitaryAuthority": ["local-authority"],
        "http://landregistry.data.gov.uk/def/ukhpi/Region": [],
        "unknown": []
      }[layerType( layer )];
    }
  };

  /** @return Special case partition keys by UK country */
  var countryPartitionKeys = function() {
    return ["country"];
  };

  var addToPartition = function( partitionTable, key, layer ) {
    if (!_.has( partitionTable, key )) {
      partitionTable[key] = Leaflet.layerGroup( [] );
    }

    partitionTable[key].addLayer( layer );
  };


  return MapView;
} );
