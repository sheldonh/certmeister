module Certmeister

  class BlackholeAuthenticator
    def authenticate(request)
      Certmeister::AuthenticationResponse.new(false, "blackholed")
    end
  end

end
