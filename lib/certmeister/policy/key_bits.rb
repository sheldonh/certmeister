require 'certmeister/policy/response'
require 'openssl'

module Certmeister

  module Policy

    class KeyBits

      DEFAULT_MIN_KEY_BITS = 4096

      attr_reader :min_key_bits

      def initialize(min_key_bits = DEFAULT_MIN_KEY_BITS)
        validate_min_key_bits(min_key_bits)
        @min_key_bits = min_key_bits
      end

      def authenticate(request)
        if not request[:pem]
          Certmeister::Policy::Response.new(false, "missing pem")
        else
          cert = OpenSSL::X509::Request.new(request[:pem])
          pkey = cert.public_key
          kbits = pkey.n.num_bytes * 8
          if kbits < @min_key_bits
            Certmeister::Policy::Response.new(false, "weak key")
          else
            Certmeister::Policy::Response.new(true, nil)
          end
        end
      rescue OpenSSL::X509::RequestError => e
        Certmeister::Policy::Response.new(false, "invalid pem (#{e.message})")
      end

      private

      def validate_min_key_bits(min_key_bits)
        unless min_key_bits.is_a?(Integer)
          raise ArgumentError.new("invalid minimum key size")
        end
      end

    end

  end

end
