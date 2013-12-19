require 'certmeister/authentication_response'

module Certmeister

  class NoopAuthenticator
    def authenticate(request)
      if request.empty?
        Certmeister::AuthenticationResponse.new(false, "empty request")
      else
        Certmeister::AuthenticationResponse.new(true, nil)
      end
    end
  end

end
