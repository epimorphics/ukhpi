# frozen_string_literal: true

module Version
  MAJOR = 1
  MINOR = 5
  PATCH = 20
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{PATCH}#{SUFFIX && ".#{SUFFIX}"}"
end
