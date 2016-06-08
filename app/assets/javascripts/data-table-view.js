/** Component for showing the queried index data as a table */

modulejs.define( "data-table-view", [
  "lib/lodash",
  "lib/jquery",
  "constants",
  "preferences",
  "aspects",
  "values"
], function(
  _,
  $,
  Constants,
  Preferences,
  Aspects,
  Values
) {
  "use strict";

  var DataTableView = function() {
    this._tableViewCompact = false;
    this.bindEvents();
  };

  _.extend( DataTableView.prototype, {
    bindEvents: function() {
      $(".c-change-table-view").on( "click", _.bind( this.onChangeTableView, this ) );
    },

    showQueryResults: function( qr ) {
      var aspects = this.preferences().aspects();
      var data = this.formulateData( qr, aspects );
      var columns = this.formulateColumns( aspects );

      googleAnalyticsDataTablesWorkaround();

      $(".c-results").removeClass( "js-hidden" );

      // this should be necessary, but the destroy:true attrib on DataTables is not working
      if ($("#results-table.dataTable").length > 0) {
        $("#results-table").DataTable().destroy( false );
        $("#results-table").children().remove();
      }

      $("#results-table").DataTable( {
        data: data,
        columns: columns,
        searching: false,
        buttons: [{
          extend: "print",
          text: "<i class='fa fa-print'></i> Print data table"
        }],
        dom: "Bfrtip",
        lengthMenu: [ [12, 24, 48, -1], [12, 24, 48, "all"] ]
      } );

      if (this.afterTableViewCallback) {
        this.afterTableViewCallback();
        this.afterTableViewCallback = null;
      }

      this.relocateWideTableButton();
    },

    preferences: function() {
      return new Preferences();
    },

    formulateData: function( qr, aspects ) {
      if (this._tableViewCompact) {
        return this.formulateDataWide( qr, aspects );
      }
      else {
        return this.formulateDataNarrow( qr, aspects );
      }
    },

    formulateDataNarrow: function( qr, aspects ) {
      var rowSets = _.map( qr.results(), function( result ) {
        var values = result.valuesFor( aspects );
        var zValues = _.zip( aspects, values );

        return _.map( zValues, function( zv ) {
          return [
            result.period(),
            formatAspectNameLong( zv[0], " " ),
            zv[1] ? Values.formatValue( zv[0], zv[1] ) : null
          ];
        } );
      } );

      return _.flatten( rowSets );
    },

    formulateDataWide: function( qr, aspects ) {
      return _.map( qr.results(), function( result ) {
        var values = result.valuesFor( aspects );
        var formattedValues = _.map( _.zip( aspects, values ), function( pair ) {
          return Values.formatValue.apply( null, pair );
        } );

        return [result.period()].concat( formattedValues );
      } );
    },

    formulateColumns: function( aspects ) {
      return this._tableViewCompact ? this.formulateColumnsWide( aspects ) : this.formulateColumnsNarrow();
    },

    formulateColumnsNarrow: function() {
      return [
        {title: "Date"},
        {title: "Measure"},
        {title: "Value", type: "num-fmt", className: "text-right"}
      ];
    },

    formulateColumnsWide: function( aspects ) {
      var aspectColumns = _.map( aspects, function( aspect ) {
        return {title: formatAspectNameShort( aspect ), className: "text-right", type: "num-fmt"};
      } );

      return [{title: "Date"}].concat( aspectColumns );
    },

    relocateWideTableButton: function() {
      if ($(".js-pre-table-actions-container .c-action").length > 0) {
        $(".js-pre-table-actions-container .c-action")
          .detach()
          .prependTo( ".dt-buttons" );
      }
    },

    // event handlers

    onChangeTableView: function() {
      this._tableViewCompact = !this._tableViewCompact;

      var buttonLabel = this._tableViewCompact ?
        "Return to narrow table view" :
        "Switch to compact table view";
      $(".c-change-table-view span").text( buttonLabel );

      $(".c-results-table-container").toggleClass( "c-results-table--compact", this._tableViewCompact );

      $("body").trigger( Constants.EVENT_PREFERENCES_CHANGE );
      this.afterTableViewCallback = function() {
        _.defer( function() {
          $(".c-results-table-container").get(0).scrollIntoView();
        } );
      };
    }

  } );


  var formatAspectNameShort = function( aspectName, sep ) {
    sep = sep || "<br />";

    var shortNames = {
      averagePrice: "avg. price (all)",
      housePriceIndex: "index (all)",
      housePriceIndexSA: "index-SA (all)",
      percentageChange: "change (all)",
      percentageAnnualChange: "annual change (all)",
      averagePriceSA: "avg. price-SA (all)",
      salesVolume: "sales volume",
      averagePriceDetached: "avg. price (det.)",
      housePriceIndexDetached: "index (det.)",
      percentageChangeDetached: "change (det.)",
      percentageAnnualChangeDetached: "annual change (det.)",
      averagePriceSemiDetached: "avg. price (semi-det.)",
      housePriceIndexSemiDetached: "index (semi-det.)",
      percentageChangeSemiDetached: "change (semi-det.)",
      percentageAnnualChangeSemiDetached: "annual change (semi-det.)",
      averagePriceTerraced: "avg. price (terr.)",
      housePriceIndexTerraced: "index (terr.)",
      percentageChangeTerraced: "change (terr.)",
      percentageAnnualChangeTerraced: "annual change (terr.)",
      averagePriceFlatMaisonette: "avg price (flat/mais.)",
      housePriceIndexFlatMaisonette: "index (flat/mais.)",
      percentageChangeFlatMaisonette: "change (flat/mais.)",
      percentageAnnualChangeFlatMaisonette: "yearly change (flat/mais.)",
      averagePriceCash: "avg. price (cash)",
      housePriceIndexCash: "index (cash)",
      percentageChangeCash: "change (cash)",
      percentageAnnualChangeCash: "yearly change (cash)",
      averagePriceMortgage: "avg. price (mtge)",
      housePriceIndexMortgage: "index (mtge)",
      percentageChangeMortgage: "change (mtge)",
      percentageAnnualChangeMortgage: "yearly change (mtge)",
      averagePriceFirstTimeBuyer: "avg. price (ftb)",
      housePriceIndexFirstTimeBuyer: "index (ftb)",
      percentageChangeFirstTimeBuyer: "change (ftb)",
      percentageAnnualChangeFirstTimeBuyer: "yearly change (ftb)",
      averagePriceFormerOwnerOccupier: "avg. price (foo)",
      housePriceIndexFormerOwnerOccupier: "index (foo)",
      percentageChangeFormerOwnerOccupier: "change (foo)",
      percentageAnnualChangeFormerOwnerOccupier: "yearly change (foo)",
      averagePriceNewBuild: "avg. price (new)",
      housePriceIndexNewBuild: "index (new)",
      percentageChangeNewBuild: "change (new)",
      percentageAnnualChangeNewBuild: "yearly change (new)",
      averagePriceExistingProperty: "avg. price (existing)",
      housePriceIndexExistingProperty: "index (existing)",
      percentageChangeExistingProperty: "change (existing)",
      percentageAnnualChangeExistingProperty: "yearly change (existing)",
    };

    return shortNames[aspectName].replace( / /g, sep );
  };

  var formatAspectNameLong = function( aspectName ) {
    return Aspects[aspectName].label;
  };

  /** This bug is caused by GA side-effecting String.prototype */
  var googleAnalyticsDataTablesWorkaround = function() {
    /** Issue https://github.com/epimorphics/ukhpi/issues/2
     * Something is adding functions to String.prototype, but I'm
     * not sure what. In any case, this causes a for..in loop in
     * jQuery dataTables to explode with a 'doesn't respond to charAt
     * message. The only workaround I have at the moment, unsatisfactorily,
     * is to remove the additional functions from the String prototype
     */
    delete String.prototype.startsWith;
    delete String.prototype.repeat;
  };

  return DataTableView;
} );
