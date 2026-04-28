module Version
  MAJOR = 2
  MINOR = 3
  PATCH = 1
  SUFFIX = nil
  VERSION = "#{MAJOR}.#{MINOR}.#{PATCH}#{SUFFIX && ".#{SUFFIX}"}".freeze
end
