# frozen_string_literal: true

module CubeDataModel
  # Concern that encapsulates an RDF resource in a DataCube model
  class CubeResource
    attr_reader :resource, :graph

    def initialize(graph, resource)
      @graph = graph
      @resource = resource
    end

    def label
      graph.query([resource, RDF::RDFS.label, nil]).first.object.to_s
    end

    def comment
      graph.query([resource, RDF::RDFS.comment, nil]).first.object.to_s
    end

    def range
      graph.query([resource, RDF::RDFS.range, nil]).first.object
    end

    def slug
      slug_mixed_case = local_name[0] + local_name.gsub(/[[:lower:]]/, '')
      slug_mixed_case.downcase
    end

    def local_name
      resource.to_s.match(%r{([^/\#]*)\Z})[1]
    end

    def uri
      resource.to_s
    end

    def qname
      "ukhpi:#{local_name}"
    end

    def objects_of(pred)
      stmts = graph.query([resource, pred, nil])
      (stmts || []).map(&:object)
    end

    def object_of(pred)
      objects_of(pred).first
    end
  end
end
