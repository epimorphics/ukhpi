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

  _.extend( MapView.prototype, {
    bindEvents: function() {
      $("a[data-toggle='tab']").on( "shown.bs.tab", _.bind( this.onShowTab, this ) );
      $("body").on( "ukhpi.prefs.revealed", _.bind( this.onRevealPreferences, this ) );
      $("body").on( "ukhpi.location-type.change", _.bind( this.onChangeLocationType, this ) );
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
      var features = Leaflet.geoJson( json, {style: defaultRegionStyle} );
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
    },

    showLayer: function( layerId, map ) {
      if (this._currentLayer) {
        map.removeLayer( this._currentLayer );
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

    resetSelection: function() {
      var f = this._selectedFeature;
      this._selectedFeature = null;
      this.unHighlightFeature( f );
    },

    unHighlightFeature: function( feature ) {
      // TODO
      // if (feature) {
      //   _geojson.resetStyle( feature );
      // }
      // if (_selectedFeature) {
      //   highlightFeature( _selectedFeature, "#e5ea08" );
      // }
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
      this.showLayer( args.locationType, this._map );
      this.showLocationSelection( args.locationType );
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
        "http://data.ordnancesurvey.co.uk/ontology/admingeo/UnitaryAuthority": ["county", "local-authority"],
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
