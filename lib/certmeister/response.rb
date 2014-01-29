module Certmeister

  class Response

    def initialize(pem, error)
      @pem = pem
      @error = error
      if @pem and @error
        raise ArgumentError.new("pem and error are mutually exclusive")
      end
    end

    def pem
      @pem
    end

    def error
      @error
    end

    def hit?
      !!@pem
    end

    def miss?
      !(hit? or error?)
    end

    def error?
      !!@error
    end

    def self.hit(pem)
      self.new(pem, nil)
    end

    def self.miss
      self.new(nil, nil)
    end

    def self.error(message)
      self.new(nil, message)
    end

  end

end
