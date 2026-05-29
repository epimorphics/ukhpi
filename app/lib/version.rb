module Version
  MAJOR = 2
  MINOR = 3
  PATCH = 3
  SUFFIX = 'prerelease'
  VERSION = "#{MAJOR}.#{MINOR}.#{PATCH}#{SUFFIX && ".#{SUFFIX}"}".freeze
end
