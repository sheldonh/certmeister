require 'time'
require 'openssl'

module Certmeister

  class Base

    def initialize(config)
      if config.valid?
        @config = config
        @authenticator = config.authenticator
        @ca_cert = config.ca_cert
        @ca_key = config.ca_key
        @openssl_digest = config.openssl_digest
      else
        raise RuntimeError.new("invalid config")
      end
    end

    def sign(request)
      if @authenticator.call(request)
        csr = OpenSSL::X509::Request.new(request[:csr])
        now = DateTime.now
        cert = OpenSSL::X509::Certificate.new
        cert.serial = 0
        cert.version = 2
        cert.not_before = now.to_time
        cert.not_after = (now + (5 * 365)).to_time
        cert.subject = csr.subject
        cert.public_key = csr.public_key
        cert.issuer = @ca_cert.subject
        cert.sign @ca_key, @openssl_digest.new
        cert.to_pem
      end
    end

  end

end
