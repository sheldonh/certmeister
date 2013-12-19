# This authenticator is broken because it violates the rule that an empty request must always be refused.

module CertmeisterAuthenticatorHelper

  class BrokenAuthenticator

    def authenticate(request)
      Certmeister::AuthenticationResponse.new(true, nil)
    end

  end

end

