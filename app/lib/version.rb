# frozen_string_literal: true

module Version
  MAJOR = 1
  MINOR = 6
  REVISION = 0
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{REVISION}#{SUFFIX && ".#{SUFFIX}"}"
end
