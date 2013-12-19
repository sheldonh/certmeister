module Certmeister

  class InMemoryStore

    def initialize(options = nil)
      @certs = {}
      @healthy = true
    end

    def store(cn, cert)
      @certs[cn] = cert
    end

    def fetch(cn)
      @certs[cn]
    end

    def health_check
      @healthy
    end

    private

    def break!
      @healthy = false
    end

  end

end
