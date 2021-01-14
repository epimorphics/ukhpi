# frozen_string_literal: true

require 'test_helper'

# :nodoc:
class CubeMeasureTest < ActiveSupport::TestCase
  let :measure0 do
    g = RDF::Graph.new
    measure = RDF::Resource.new('http://landregistry.data.gov.uk/def/ukhpi/salesVolume')

    g.from_ttl <<~GRAPH
      @prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
      @prefix owl:   <http://www.w3.org/2002/07/owl#> .
      @prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .
      @prefix api:   <http://purl.org/linked-data/api/vocab#> .
      @prefix def-ukhpi: <http://landregistry.data.gov.uk/def/ukhpi/> .
      @prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
      @prefix qb:    <http://purl.org/linked-data/cube#> .
      @prefix dcterms: <http://purl.org/dc/terms/> .
      def-ukhpi:salesVolume
            a             owl:DatatypeProperty , qb:MeasureProperty ;
            rdfs:comment  "Volume of sales upon which analysis is based"@en ;
            rdfs:label    "Sales volume"@en ;
            rdfs:range    xsd:integer ;
            <http://qudt.org/schema/qudt#unit>  <http://dbpedia.org/resource/Number> .
    GRAPH

    CubeDataModel::CubeMeasure.new(g, measure)
  end

  let :measure1 do
    g = RDF::Graph.new
    measure = RDF::Resource.new('http://landregistry.data.gov.uk/def/ukhpi/percentageChangeDetached')

    g.from_ttl <<~GRAPH
      @prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
      @prefix owl:   <http://www.w3.org/2002/07/owl#> .
      @prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .
      @prefix api:   <http://purl.org/linked-data/api/vocab#> .
      @prefix def-ukhpi: <http://landregistry.data.gov.uk/def/ukhpi/> .
      @prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
      @prefix qb:    <http://purl.org/linked-data/cube#> .
      @prefix dcterms: <http://purl.org/dc/terms/> .
      def-ukhpi:percentageChangeDetached
        a             owl:DatatypeProperty , qb:MeasureProperty ;
        rdfs:comment  "The percentage change for the average detached property price compared to the previous reference period, aggregated over the given reference period."@en ;
        rdfs:label    "Detached property price percentage change"@en ;
        rdfs:range    xsd:decimal ;
        <http://qudt.org/schema/qudt#unit>  <http://dbpedia.org/resource/Percentage> .
    GRAPH

    CubeDataModel::CubeMeasure.new(g, measure)
  end

  describe 'CubeMeasure' do
    it 'should return the units' do
      _(measure0.units.map(&:to_s)).must_equal ['http://dbpedia.org/resource/Number']
    end

    it 'should return the range' do
      _(measure0.range.map(&:to_s)).must_equal [RDF::XSD.integer.to_s]
    end

    it 'should return true for a percentage measure' do
      _(measure0.percentage?).must_equal false
      _(measure1.percentage?).must_equal true
    end

    it 'should return the unit type' do
      _(measure0.unit_type).must_equal :integer
      _(measure1.unit_type).must_equal :percentage
    end
  end
end
