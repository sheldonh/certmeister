require 'certmeister/policy/response'

module Certmeister

  module Policy

    class Blackhole
      def authenticate(request)
        Certmeister::Policy::Response.new(false, "blackholed")
      end
    end

  end

end
