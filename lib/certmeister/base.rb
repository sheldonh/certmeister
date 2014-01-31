require 'time'
require 'openssl'

module Certmeister

  class Base

    def initialize(config)
      if config.valid?
        @sign_policy = config.sign_policy
        @fetch_policy = config.fetch_policy
        @remove_policy = config.remove_policy
        @ca_cert = config.ca_cert
        @ca_key = config.ca_key
        @store = config.store
        @openssl_digest = config.openssl_digest
      else
        reasons = config.errors.map { |kv| kv.join(' ') }
        raise RuntimeError.new("invalid config: #{reasons.join('; ')}")
      end
    end

    def sign(request)
      subject_to_policy(@sign_policy, request) do |request|
        begin
          csr = OpenSSL::X509::Request.new(request[:csr])
        rescue OpenSSL::OpenSSLError => e
          Certmeister::Response.error("invalid CSR (#{e.message})")
        else
          if get_cn(csr) == request[:cn]
            pem = create_signed_certificate(csr).to_pem
            @store.store(request[:cn], pem)
            Certmeister::Response.hit(pem)
          else
            Certmeister::Response.error("CSR subject (#{get_cn(csr)}) disagrees with request CN (#{request[:cn]})")
          end
        end
      end
    end

    def fetch(request)
      subject_to_policy(@fetch_policy, request) do |request|
        if pem = @store.fetch(request[:cn])
          Certmeister::Response.hit(pem)
        else
          Certmeister::Response.miss
        end
      end
    end

    def remove(request)
      subject_to_policy(@remove_policy, request) do |request|
        if @store.remove(request[:cn])
          Certmeister::Response.hit
        else
          Certmeister::Response.miss
        end
      end
    end

    private

    def subject_to_policy(policy, request, &block)
      if !request[:cn]
        Certmeister::Response.error("request missing CN")
      else
        authentication = policy.authenticate(request)
        if authentication.authenticated?
          block.call(request)
        else
          Certmeister::Response.error("request refused (#{authentication.error})")
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
