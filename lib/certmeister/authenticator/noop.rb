require 'certmeister/authenticator/response'

module Certmeister

  module Authenticator

    class Noop
      def authenticate(request)
        if request.empty?
          Certmeister::Authenticator::Response.new(false, "empty request")
        else
          Certmeister::Authenticator::Response.new(true, nil)
        end
      end
    end

  end

end
