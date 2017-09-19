# frozen_string_literal: true

module CubeDataModel
  # RDF vocabularies for the key concepts in the Cube data model for UKHPI
  module Vocabularies
    QB = RDF::Vocabulary.new('http://purl.org/linked-data/cube#')
    UKHPI = RDF::Vocabulary.new('http://landregistry.data.gov.uk/def/ukhpi/')
    QUDT = RDF::Vocabulary.new('http://qudt.org/schema/qudt#')
  end
end
