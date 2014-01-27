require 'certmeister/policy/response'

module Certmeister

  module Policy

    class Noop
      def authenticate(request)
        Certmeister::Policy::Response.new(true, nil)
      end
    end

  end

end
