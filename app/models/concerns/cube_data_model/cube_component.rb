# frozen_string_literal: true

module CubeDataModel
  # Module encapsulating the concern of a Component in a data cube, which
  # specialises a generic resource by having a qb:component property denoting
  # a bNode that is either a dimension or a measure
  class CubeComponent < CubeResource
    include CubeDataModel::Vocabularies

    # @return True if this component has a value that denotes a dimension
    def dimension?
      !graph.query([resource, QB.dimension, nil]).empty?
    end

    # @return True if this component has a value that denotess a measure
    def measure?
      !graph.query([resource, QB.measure, nil]).empty?
    end

    # @return [CubeMeasure] The cube measure object that this component denotes
    def measure
      r = graph.query([resource, QB.measure, nil]).first
      CubeDataModel::CubeMeasure.new(graph, r.object) if r
    end

    # @return [CubeDimension] The cube dimension object that this component denotes
    def dimension
      r = graph.query([resource, QB.dimension, nil]).first
      CubeDataModel::CubeDimension.new(graph, r.object) if r
    end
  end
end
