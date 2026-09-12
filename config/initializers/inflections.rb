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

# Zeitwerk works out the constant name a file should define from its filename,
# before any code in that file runs. An acronym therefore has to be declared
# here, ahead of the first reference to the constant. Declaring it inside the
# file it names cannot work, which is what app/models/concerns/cube_data_model/
# dsd.rb used to do: CubeDataModel::DSD then resolved only by accident of load
# order, and failed whenever nothing else had loaded that file first.
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'DSD'
end
