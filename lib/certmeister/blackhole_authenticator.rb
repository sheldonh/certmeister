require 'certmeister/authentication_response'

module Certmeister

  class BlackholeAuthenticator
    def authenticate(request)
      if request.empty?
        Certmeister::AuthenticationResponse.new(false, "empty request")
      else
        Certmeister::AuthenticationResponse.new(false, "blackholed")
      end
    end
  end

end
