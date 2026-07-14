module Version
  MAJOR = 2
  MINOR = 3
  PATCH = 4
  SUFFIX = 'prerelease'
  VERSION = "#{MAJOR}.#{MINOR}.#{PATCH}#{SUFFIX && ".#{SUFFIX}"}".freeze
end
