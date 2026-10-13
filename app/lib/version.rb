module Version
  MAJOR = 2
  MINOR = 4
  PATCH = 2
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{PATCH}#{SUFFIX && ".#{SUFFIX}"}".freeze
end
