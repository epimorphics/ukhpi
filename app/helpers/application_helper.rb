# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  def active_class(path)
    'u-active' if request.path == path
  end
end
