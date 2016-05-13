/* Component for rendering the map outlines as means of selecting regions */

modulejs.define( "map-view", [
  "lib/lodash",
  "lib/jquery",
  "lib/leaflet",
  "routes"
],
function(
  _,
  $,
  Leaflet,
  Routes
) {
  "use strict";

  var MapView = function() {
    this.fetchFeatures();
    this.bindEvents();
  };

  _.extend( MapView.prototype, {
    bindEvents: function() {
      $("a[data-toggle='tab']").on( "shown.bs.tab", _.bind( this.onShowTab, this ) );
      $("body").on( "ukhpi.prefs.revealed", _.bind( this.onRevealPreferences, this ) );
    },

    fetchFeatures: function() {
      $.getJSON( Routes.public_path + "features.json" )
       .done( _.bind( this.onFeaturesLoaded, this ) )
       .error( function( e, m, a ) {
          console.log( "API get failed: " );
          console.log( e );
          console.log( m );
          console.log( a );
       } );
    },

    onFeaturesLoaded: function( json ) {
      var features = Leaflet.geoJson( json, {style: defaultRegionStyle} );
      this._featuresPartition = this.partitionFeatures( features );
    },

    show: function() {
      if (!this._map) {
        var map = this.createMap();
        this._featuresPartition.country.addTo( map );
      }
    },

    partitionFeatures: function( features ) {
      var featuresPartition = {};

      features.eachLayer( function( layer ) {
        var featureType = layer.feature.properties.ukhpiType;
        if (!_.has( featuresPartition, featureType )) {
          featuresPartition[featureType] = Leaflet.layerGroup( [] );
        }

        featuresPartition[featureType].addLayer( layer );
      } );

      return featuresPartition;
    },

    createMap: function() {
      if (!this._map) {
        this._map = Leaflet.map( "map" )
                           .setView( [53.0072, -2], 6 );
        this._map.attributionControl.setPrefix( "Contains Ordnance Survey data &copy; Crown copyright 2016" );
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
        this.show();
      }
    },

    onRevealPreferences: function( e ) {
      this.show();
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


  return MapView;
} );
