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
      pem = nil
      error = nil
      if @authenticator.call(request)
        begin
          csr = OpenSSL::X509::Request.new(request[:csr])
        rescue OpenSSL::OpenSSLError => e
          error = "invalid CSR (#{e.message})"
        else
          if get_cn(csr) == request[:cn]
            pem = create_signed_certificate(csr).to_pem
          else
            error = "CSR subject (#{get_cn(csr)}) disagrees with request CN (#{request[:cn]})"
          end
        end
      else
        error = "request could not be authenticated"
      end
      Certmeister::SigningResponse.new(pem, error)
    end

    private

    def create_signed_certificate(csr)
      cert = OpenSSL::X509::Certificate.new

      cert.serial = 0
      cert.version = 2
      cert.subject = csr.subject
      cert.public_key = csr.public_key

      now = DateTime.now
      cert.not_before = now.to_time
      cert.not_after = (now + (5 * 365)).to_time
      cert.issuer = @ca_cert.subject
      cert.sign @ca_key, @openssl_digest.new

      cert
    end

    def get_cn(csr)
      if csr.subject.to_s =~ /CN=(.+)$/
        $1
      end
    end

  end

end
