require 'time'
require 'openssl'

module Certmeister

  class Base

    def initialize(config)
      if config.valid?
        @sign_policy = config.sign_policy
        @ca_cert = config.ca_cert
        @ca_key = config.ca_key
        @store = config.store
        @openssl_digest = config.openssl_digest
      else
        raise RuntimeError.new("invalid config")
      end
    end

    def sign(request)
      if !request[:cn]
        Certmeister::SigningResponse.new(nil, "request missing CN")
      else
        authentication = @sign_policy.authenticate(request)
        if authentication.authenticated?
          really_sign(request)
        else
          Certmeister::SigningResponse.new(nil, "request refused (#{authentication.error})")
        end
      end
    end

    def fetch(request)
      @store.fetch(request[:cn])
    end

    def remove(cn)
      !!@store.remove(cn)
    end

    private

    def really_sign(request)
      begin
        csr = OpenSSL::X509::Request.new(request[:csr])
      rescue OpenSSL::OpenSSLError => e
        Certmeister::SigningResponse.new(nil, "invalid CSR (#{e.message})")
      else
        if get_cn(csr) == request[:cn]
          pem = create_signed_certificate(csr).to_pem
          @store.store(request[:cn], pem)
          Certmeister::SigningResponse.new(pem, nil)
        else
          Certmeister::SigningResponse.new(nil, "CSR subject (#{get_cn(csr)}) disagrees with request CN (#{request[:cn]})")
        end
      end
    end

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
