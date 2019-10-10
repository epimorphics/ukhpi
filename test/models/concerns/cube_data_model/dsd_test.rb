# frozen_string_literal: true

require 'test_helper'

# Unit tests on the DSD class
class DsdTest < ActiveSupport::TestCase
  let :dsd do
    g = RDF::Graph.new

    g.from_ttl <<~GRAPH
      @prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
      @prefix owl:   <http://www.w3.org/2002/07/owl#> .
      @prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .
      @prefix api:   <http://purl.org/linked-data/api/vocab#> .
      @prefix def-ukhpi: <http://landregistry.data.gov.uk/def/ukhpi/> .
      @prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
      @prefix qb:    <http://purl.org/linked-data/cube#> .
      @prefix dcterms: <http://purl.org/dc/terms/> .

      def-ukhpi:datasetDefinition
        a             qb:DataStructureDefinition ;
        qb:component  [ qb:dimension  def-ukhpi:refRegion ] ;
        qb:component  [ qb:measure  def-ukhpi:averagePrice ] ;
        .

        def-ukhpi:refRegion  a  owl:ObjectProperty , qb:DimensionProperty ;
          rdfs:comment  "The administrative areas that Land Registry"@en ;
          rdfs:label    "Region"@en ;
          rdfs:range    def-ukhpi:Region .

          def-ukhpi:averagePrice
            a             owl:DatatypeProperty , qb:MeasureProperty ;
            rdfs:comment  "Average price at Country, Regional, County/Unitary/District Authority"@en ;
            rdfs:label    "Average price"@en ;
            rdfs:range    xsd:integer ;
            <http://qudt.org/schema/qudt#unit>
            <http://dbpedia.org/resource/Pound_sterling> .
    GRAPH

    CubeDataModel::DSD.new(g, CubeDataModel::Vocabularies::UKHPI.datasetDefinition)
  end

  it 'should return a collection of components' do
    _(dsd.components.length).must_equal 2
  end

  it 'should return a collection of only dimensions' do
    _(dsd.dimensions.length).must_equal 1
    _(dsd.dimensions.first.uri).must_equal 'http://landregistry.data.gov.uk/def/ukhpi/refRegion'
  end

  it 'should return a collection of only measures' do
    _(dsd.measures.length).must_equal 1
    _(dsd.measures.first.uri).must_equal 'http://landregistry.data.gov.uk/def/ukhpi/averagePrice'
  end
end
