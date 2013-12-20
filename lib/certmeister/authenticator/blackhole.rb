require 'certmeister/authenticator/response'

module Certmeister

  module Authenticator

    class Blackhole
      def authenticate(request)
        if request.empty?
          Certmeister::Authenticator::Response.new(false, "empty request")
        else
          Certmeister::Authenticator::Response.new(false, "blackholed")
        end
      end
    end

  end

end
