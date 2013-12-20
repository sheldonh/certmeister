require 'certmeister/authenticator'

module Certmeister

  module Authenticator

    class ChainAll

      def initialize(authenticators)
        validate_authenticators(authenticators)
        @authenticators = authenticators
      end

      def authenticate(request)
        if request.empty?
          Certmeister::Authenticator::Response.new(false, "empty request")
        else
          success = Certmeister::Authenticator::Response.new(true, nil)
          @authenticators.inject(success) do |continue, authenticator|
            response = authenticator.authenticate(request)
            if response.authenticated?
              continue
            else
              break response
            end
          end
        end
      end

      private

      def validate_authenticators(authenticators)
        unless authenticators.is_a?(Enumerable) and authenticators.respond_to?(:size) and authenticators.size > 0 and
               authenticators.all? { |authenticator| Certmeister::Authenticator.validate_authenticate_signature(authenticator) } and
               authenticators.all? { |authenticator| Certmeister::Authenticator.validate_authenticate_refuses_empty(authenticator) }
          raise ArgumentError.new("enumerable collection of authenticators required")
        end
      end

    end

  end

end
