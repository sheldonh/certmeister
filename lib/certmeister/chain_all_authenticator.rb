require 'certmeister/authentication_response'
require 'certmeister/authenticator'

module Certmeister

  class ChainAllAuthenticator

    def initialize(authenticators)
      validate_authenticators(authenticators)
      @authenticators = authenticators
    end

    def authenticate(request)
      if request.empty?
        Certmeister::AuthenticationResponse.new(false, "empty request")
      else
        success = Certmeister::AuthenticationResponse.new(true, nil)
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
