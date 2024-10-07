# frozen_string_literal: true

module Version
  MAJOR = 1
  MINOR = 7
  PATCH = 6
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{PATCH}#{SUFFIX && ".#{SUFFIX}"}"
end
