# frozen_string_literal: true

module Version
  MAJOR = 1
  MINOR = 5
  REVISION = 20
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{REVISION}#{SUFFIX && ".#{SUFFIX}"}"
end
