# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end

# Tells Zeitwerk that app/models/concerns/cube_data_model/dsd.rb defines
# CubeDataModel::DSD rather than CubeDataModel::Dsd. This has to be declared
# here, ahead of any reference to the constant: declaring it inside dsd.rb
# itself is circular (Zeitwerk derives the constant name from the filename
# before anything in the file can run) and left the constant resolvable only
# by accident of load order.
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'DSD'
end
