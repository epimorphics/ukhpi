# frozen_string_literal: true

module Version
  MAJOR = 2
  MINOR = 2
  PATCH = 1
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{PATCH}#{SUFFIX && ".#{SUFFIX}"}".freeze
end
