module Certmeister

  class Base

    def initialize(config)
      if config.valid?
        @config = config
      else
        raise RuntimeError.new("invalid config")
      end
    end

  end

end
