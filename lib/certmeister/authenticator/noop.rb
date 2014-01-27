require 'certmeister/authenticator/response'

module Certmeister

  module Authenticator

    class Noop
      def authenticate(request)
        Certmeister::Authenticator::Response.new(true, nil)
      end
    end

  end

end
