# frozen_string_literal: true

# rubocop:disable Layout/LineLength
namespace :ukhpi do
  desc 'Create the DSAPI config file from the current DSD'
  task dsapi_config: :environment do
    ukhpi_data_cube = UkhpiDataCube.new
    FILENAME = 'config/dsapi/ukhpi.ttl'

    File.open(FILENAME, 'w') do |file|
      file << <<~PREFIXES
        @prefix owl:   <http://www.w3.org/2002/07/owl#> .
        @prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
        @prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
        @prefix skos:  <http://www.w3.org/2004/02/skos/core#> .
        @prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .
        @prefix dct:   <http://purl.org/dc/terms/> .
        @prefix qb:    <http://purl.org/linked-data/cube#> .
        @prefix wfd: <http://location.data.gov.uk/def/am/wfd/> .
        @prefix ukhpi: <http://landregistry.data.gov.uk/def/ukhpi/> .
        @prefix dsapi: <http://www.epimorphics.com/public/vocabulary/dsapi#> .
        @prefix admingeo: <http://data.ordnancesurvey.co.uk/ontology/admingeo/> .
        @prefix sr:    <http://data.ordnancesurvey.co.uk/ontology/spatialrelations/> .
        @prefix :  <http://landregistry.data.gov.uk/dsapi/hpi#> .

      PREFIXES

      file << <<~PREAMBLE
        :ukhpi a dsapi:Dataset;
          rdfs:label "UK house price index";
          dct:description "A Data Cube of UK house price index data from Land Registry";
          dsapi:source "source3";
          dsapi:aspect
      PREAMBLE

      ukhpi_data_cube.dsd.dimensions.each do |dim|
        file << "    [rdfs:label \"#{dim.label}\" ; dsapi:property #{dim.qname}],\n"
      end

      ukhpi_data_cube.dsd.measures.each do |measure|
        file << "    [rdfs:label \"#{measure.label}\" ; dsapi:property #{measure.qname} ; dsapi:optional true ],\n"
      end

      file << <<~POSTAMBLE
        [rdfs:label    "Reference period start" ; dsapi:property ukhpi:refPeriodStart ; dsapi:optional true ] ,
        [rdfs:label    "Reference period duration" ; dsapi:property ukhpi:refPeriodDuration ; dsapi:optional true ]
        .
      POSTAMBLE
    end
  end
end
# rubocop:enable Layout/LineLength
