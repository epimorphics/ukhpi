# frozen-string-literal: true

# Decorator-pattern class for creating presentations and renderings of
# UserSelections objects
class UserSelectionsPresenter
  attr_reader :selections

  def initialize(user_selections)
    @selections = user_selections
  end

  # Present the contained user-selections in a form suitable for the query
  # params of a URL link
  def as_url_search_string
    params
      .map(&method(:encode_for_url_search_string))
      .sort
      .join('&')
  end

  # Present the contained user-selections as a title, by summarising the
  # key identifying information
  def as_title
    templates = {
      location: '%s',
      from: 'from %s',
      to: 'to %s'
    }

    apply_templates(templates, params).join(' ')
  end

  private

  def params
    selections.params.to_h
  end

  def encode_for_url_search_string(args)
    k, vs = *args
    if vs.is_a?(Array)
      k = "#{k}[]"
    else
      vs = [vs]
    end

    vs
      .map { |v| "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}" }
      .join('&')
  end

  def apply_templates(templates, params)
    templates.map do |key, template|
      if (value = params[key])
        template % format_selection_value(value)
      end
    end .compact
  end

  def format_selection_value(value)
    if (r = Locations.lookup_location(value))
      r.label
    elsif value.is_a?(Date)
      value.strftime('%B %Y')
    else
      value.to_s
    end
  end
end
