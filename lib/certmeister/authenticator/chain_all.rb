require 'certmeister/authenticator'

module Certmeister

  module Authenticator

    class ChainAll

      def initialize(authenticators)
        validate_authenticators(authenticators)
        @authenticators = authenticators
      end

      def authenticate(request)
        success = Certmeister::Authenticator::Response.new(true, nil)
        @authenticators.inject(success) do |continue, authenticator|
          response = authenticator.authenticate(request)
          break response unless response.authenticated?
          continue
        end
      end

      private

      def validate_authenticators(authenticators)
        unless authenticators.is_a?(Enumerable) and authenticators.respond_to?(:size) and authenticators.size > 0 and
               authenticators.all? { |authenticator| Certmeister::Authenticator.validate_authenticate_signature(authenticator) }
          raise ArgumentError.new("enumerable collection of authenticators required")
        end
      end

    end

  end

end
