module Version
  MAJOR = 2
  MINOR = 3
  PATCH = 2
  SUFFIX = ''
  VERSION = "#{MAJOR}.#{MINOR}.#{PATCH}#{SUFFIX && ".#{SUFFIX}"}".freeze
end
