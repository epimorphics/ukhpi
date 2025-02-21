# frozen_string_literal: true

module CubeDataModel
  # Specialises a CubeResource to add behaviour specific to DataCube measures
  class CubeMeasure < CubeResource
    include CubeDataModel::Vocabularies

    def units
      objects_of(QUDT.unit)
    end

    def range
      objects_of(RDF::RDFS.range)
    end

    def scalar?
      units.include?(DBPEDIA_RESOURCE.Scalar)
    end

    def percentage?
      units.include?(DBPEDIA_RESOURCE.Percentage)
    end

    def pound_sterling?
      units.include?(DBPEDIA_RESOURCE.Pound_sterling)
    end

    def integer_range?
      range.include?(RDF::XSD.integer)
    end

    def decimal_range?
      range.include?(RDF::XSD.decimal)
    end

    def unit_type
      if scalar?
        :scalar
      elsif percentage?
        :percentage
      elsif pound_sterling?
        :pound_sterling
      elsif integer_range?
        :integer
      elsif decimal_range?
        :decimal
      else
        :unknown
      end
    end
  end
end
