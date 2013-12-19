module Certmeister

  class AuthenticationResponse

    def initialize(authenticated, error)
      @authenticated = authenticated
      @error = error
    end

    def authenticated?
      !@error
    end

    def error
      @error
    end

  end

end
