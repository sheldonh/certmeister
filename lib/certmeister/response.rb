module Certmeister

  class Response

    private_class_method :new

    def initialize(type, pem, error)
      @type = type
      @pem = pem
      @error = error
    end

    def pem
      @pem
    end

    def error
      @error
    end

    def hit?
      @type == :hit
    end

    def miss?
      @type == :miss
    end

    def denied?
      @type == :denied
    end

    def error?
      @type == :error
    end

    def self.hit(pem = :none)
      new(:hit, pem, nil)
    end

    def self.miss
      new(:miss, nil, nil)
    end

    def self.denied(message)
      new(:denied, nil, message)
    end

    def self.error(message)
      new(:error, nil, message)
    end

  end

end
