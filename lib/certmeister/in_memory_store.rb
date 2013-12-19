require 'certmeister/store_exception'

module Certmeister

  class InMemoryStore

    def initialize(options = nil)
      @certs = {}
      @healthy = true
    end

    def store(cn, cert)
      raise Certmeister::StoreException if !@healthy
      @certs[cn] = cert
    end

    def fetch(cn)
      raise Certmeister::StoreException if !@healthy
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
