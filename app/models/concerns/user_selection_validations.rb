# frozen-string-literal: true

# A collection of validation rules we apply to check whether a given set of user
# input selections is valid
module UserSelectionValidations
  def valid?
    validate
    errors.empty?
  end

  def errors
    @errors ||= []
  end

  def validate
    validate_date(:from_date, 'incorrect or missing "from" date')
    validate_date(:to_date, 'incorrect or missing "to" date')
    validate_location('unrecognised location')
    validate_indicator('unrecognised indicator(s)')
    validate_statistic('unrecognised statistic(s)')
  end

  def validate_date(method, msg)
    errors << msg if send(method).nil?
  rescue ArgumentError => _e
    errors << msg
  end

  def validate_location(msg)
    errors << msg if selected_location.nil? || Locations.lookup_location(selected_location).nil?
  end

  def validate_indicator(msg)
    if selected_indicators.empty?
      errors << msg
    else
      cube = UkhpiDataCube.new
      inds = selected_indicators.map { |ind| cube.indicator(ind) }
      errors << msg if inds.include?(nil)
    end
  end

  def validate_statistic(msg)
    if selected_statistics.empty?
      errors << msg
    else
      cube = UkhpiDataCube.new
      stats = selected_statistics.map { |stat| cube.statistic(stat) }
      errors << msg if stats.include?(nil)
    end
  end
end
