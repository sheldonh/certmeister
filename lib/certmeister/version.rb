require 'semver'

module Certmeister

  VERSION = SemVer.find.format("%M.%m.%p%s") unless defined?(VERSION)
  
end
