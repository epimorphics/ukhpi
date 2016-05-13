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
  };

  _.extend( MapView.prototype, {
    fetchFeatures: function() {
      $.getJSON( Routes.public_path + "/features.json" )
       .done( _.bind( this.onFeaturesLoaded, this ) )
       .error( function( e, m, a ) {
          console.log( "API get failed: " );
          console.log( e );
          console.log( m );
          console.log( a );
       } );
    },

    onFeaturesLoaded: function( json ) {
      var features = Leaflet.geoJson(
        json,
        {style: featureStyle}
      );
      debugger;
    }
  } );

  var featureStyle = function() {
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
