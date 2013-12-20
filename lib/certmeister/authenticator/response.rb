module Certmeister

  module Authenticator

    class Response

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

end
