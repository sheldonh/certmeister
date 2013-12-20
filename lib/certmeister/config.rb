require 'openssl'

require 'certmeister/authenticator'

module Certmeister

  class Config

    attr_reader :store, :authenticator

    def initialize(options)
      @options = options
      @store = options[:store]
      @authenticator = options[:authenticator]
      @errors = {}
    end

    def ca_cert
      @ca_cert ||= OpenSSL::X509::Certificate.new(@options[:ca_cert])
    end

    def ca_key
      @ca_key ||= OpenSSL::PKey.read(@options[:ca_key])
    end

    def openssl_digest
      if OpenSSL::Digest.const_defined?('SHA256')
        @digest = OpenSSL::Digest::SHA256
      elsif OpenSSL::Digest.const_defined?('SHA1')
        @digest = OpenSSL::Digest::SHA1
      end
    end

    def valid?
      validate
      @errors.empty?
    end

    def errors
      @errors
    end

    def error_list
      @errors.keys.sort.inject([]) do |list, option|
        list << "#{option} #{@errors[option]}"
      end
    end

    private

    def validate
      validate_x509_pem(:ca_cert)
      validate_pkey_pem(:ca_key)
      validate_store(:store)
      validate_authenticator(:authenticator)
      validate_openssl_digest
      validate_known_options
    end

    def validate_x509_pem(option)
      if not @options[option]
        @errors[option] = "is required"
      else
        begin
          OpenSSL::X509::Certificate.new(@options[option])
        rescue OpenSSL::OpenSSLError => e
          @errors[option] = "must be a PEM-encoded x509 certificate (#{e.message})"
        end
      end
    end

    def validate_pkey_pem(option)
      if not @options[option]
        @errors[option] = "is required"
      else
        begin
          OpenSSL::PKey.read(@options[option])
        rescue ArgumentError => e
          @errors[option] = "must be a PEM-encoded private key (#{e.message})"
        end
      end
    end

    def validate_store(option)
      o = @options[option]
      if not o
        @errors[option] = "is required"
      elsif not o.respond_to?(:store) or o.method(:store).arity != 2
        @errors[option] = "must provide a binary store method"
      elsif not o.respond_to?(:fetch) or o.method(:fetch).arity != 1
        @errors[option] = "must provide a unary fetch method"
      elsif not o.respond_to?(:health_check) or o.method(:health_check).arity != 0
        @errors[option] = "must provide a nullary health_check method"
      end
    end

    def validate_authenticator(option)
      o = @options[option]
      if not o
        @errors[option] = "is required"
      elsif not Certmeister::Authenticator.validate_authenticate_signature(@options[option])
        @errors[option] = "must provide a unary authenticate method"
      elsif not Certmeister::Authenticator.validate_authenticate_refuses_empty(@options[option])
        @errors[option] = "authenticator violates API"
      end
    end

    def validate_openssl_digest
      if not openssl_digest
        @errors[:openssl_digest] = "can't find FIPS 140-2 compliant algorithm in OpenSSL::Digest"
      end
    end

    def validate_known_options
      unexpected = @options.keys - [:ca_cert, :ca_key, :store, :authenticator]
      unexpected.each do |option|
        @errors[option] = "is not a supported option"
      end
    end

  end

end
