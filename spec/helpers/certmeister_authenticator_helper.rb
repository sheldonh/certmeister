# This authenticator is broken because it violates the rule that an empty request must always be refused.

module CertmeisterAuthenticatorHelper

  class BrokenAuthenticator

    def authenticate(request)
      :white_elephant
    end

  end

end

