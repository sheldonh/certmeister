begin

  require 'semver'

  module Certmeister

    VERSION = SemVer.find.format("%M.%m.%p%s") unless defined?(VERSION)
    
  end

rescue LoadError

  $stderr.puts "warning: ignoring missing semver gem for initial bundle"
  $stderr.puts "warning: please run bundle again to fix certmeister version number"

  module Certmeister

    VERSION = '0'

  end

end

    
