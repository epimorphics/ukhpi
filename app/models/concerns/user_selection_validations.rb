# frozen-string-literal: true

# A collection of validation rules we apply to check whether a given set of user
# input selections is valid
module UserSelectionValidations
  def valid?
    validate && errors.empty?
  end

  def errors
    @errors ||= []
  end

  def validate
    true
  end
end
