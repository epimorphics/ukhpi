# An encapsulation of the DSD denoting the RDF cube data model for UKHPI

class CubeResource
  attr_reader :resource, :graph

  def initialize( graph, resource )
    @graph = graph
    @resource = resource
  end

  def label
    @graph.query( [@resource, RDF::RDFS.label, nil] ).first.object.to_s
  end

  def comment
    byebug if @graph.query( [@resource, RDF::RDFS.comment, nil] ).first.nil?
    @graph.query( [@resource, RDF::RDFS.comment, nil] ).first.object.to_s
  end

  def range
    @graph.query( [@resource, RDF::RDFS.range, nil] ).first.object
  end

  def slug
    slug_mixed_case = local_name[0] + local_name.gsub( /[[:lower:]]/, "" )
    slug_mixed_case.downcase
  end

  def local_name
    @resource.to_s.match( /([^\/\#]*)\Z/ )[1]
  end

  def uri
    @resource.to_s
  end

  def qname
    "ukhpi:#{local_name}"
  end
end

class CubeComponent < CubeResource
  def dimension?
    ! @graph.query( [@resource, DataModel::QB.dimension, nil] ).empty?
  end

  def measure?
    ! @graph.query( [@resource, DataModel::QB.measure, nil] ).empty?
  end

  def measure
    r = @graph.query( [@resource, DataModel::QB.measure, nil] ).first.object
    CubeMeasure.new( @graph, r )
  end

  def dimension
    r = @graph.query( [@resource, DataModel::QB.dimension, nil] ).first.object
    CubeDimension.new( @graph, r )
  end
end

class CubeMeasure < CubeResource
  def unit
    @graph.query( [@resource, DataModel::QUDT.unit, nil] ).first.object
  end

  def range
    @graph.query( [@resource, RDF::RDFS.range, nil] ).first.object
  end

  def scalar?
    unit == RDF::Resource.new( "http://dbpedia.org/page/Scalar" )
  end

  def percentage?
    unit == RDF::Resource.new( "http://dbpedia.org/resource/Percentage" )
  end

  def pound_sterling?
    unit == RDF::Resource.new( "http://dbpedia.org/resource/Pound_sterling" )
  end

  def integer_range?
    range == RDF::XSD.integer
  end

  def decimal_range?
    range == RDF::XSD.decimal
  end

  def unit_type
    case
    when scalar?
      :scalar
    when percentage?
      :percentage
    when pound_sterling?
      :pound_sterling
    when integer_range?
      :integer
    when decimal_range?
      :decimal
    else
      :unknown
    end
  end

end

class CubeDimension < CubeResource
end

class DataModel
  # RDF vocabularies
  QB = RDF::Vocabulary.new( "http://purl.org/linked-data/cube#" )
  UKHPI = RDF::Vocabulary.new( "http://landregistry.data.gov.uk/def/ukhpi/" )
  QUDT = RDF::Vocabulary.new( "http://qudt.org/schema/qudt#" )

  def initialize
    load_model
  end

  def model
    @@model
  end

  def components
    model
      .query( [UKHPI.datasetDefinition, QB.component, nil] )
      .map {|stmt| CubeComponent.new( model, stmt.object )}
  end

  def measures
    components
      .select( &:"measure?")
      .map( &:measure)
  end

  def dimensions
    components
      .select( &:"dimension?")
      .map( &:dimension)
  end

  :private

  def load_model
    unless defined?( @@model )
      read_data_model
    end
  end

  def read_data_model
    file = File.join( Rails.root, "config", "dsapi", "UKHPI-dsd.ttl" )
    @@model = RDF::Graph.load( file, format:  :ttl )
  end
end
