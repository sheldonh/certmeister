require 'certmeister/authenticator/response'

module Certmeister

  module Authenticator

    class Blackhole
      def authenticate(request)
        Certmeister::Authenticator::Response.new(false, "blackholed")
      end
    end

  end

end
