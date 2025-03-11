# frozen_string_literal: true

module Version
  MAJOR = 2
  MINOR = 0
  PATCH = 2
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{PATCH}#{SUFFIX && ".#{SUFFIX}"}".freeze
end
