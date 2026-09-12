# The DSD acronym is declared in config/initializers/inflections.rb, which runs
# before anything can reference this constant. It cannot be declared here:
# Zeitwerk derives the expected constant name from the filename before any code
# in this file runs.
module CubeDataModel
  # Encapsulates a DataCube DSD
  class DSD
    include CubeDataModel::Vocabularies

    attr_reader :graph, :root

    def initialize(graph, root)
      @graph = graph
      @root = root
    end

    def components
      graph
        .query([ root, QB.component, nil ])
        .map { |stmt| CubeComponent.new(graph, stmt.object) }
    end

    def measures
      components
        .select(&:measure?)
        .map(&:measure)
    end

    def dimensions
      components
        .select(&:dimension?)
        .map(&:dimension)
    end
  end
end
