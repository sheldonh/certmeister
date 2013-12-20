module Certmeister

  module Authenticator

    def self.validate_authenticate_signature(authenticator)
      authenticator and authenticator.respond_to?(:authenticate) and authenticator.method(:authenticate).arity == 1
    end

    def self.validate_authenticate_refuses_empty(authenticator)
      response = authenticator.authenticate({})
      response.respond_to?(:authenticated?) and !response.authenticated? and response.error == "empty request"
    end

  end

end
