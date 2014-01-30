module Certmeister

  module Redis

    class Store

      def initialize(redis)
        @redis = redis
        @healthy = true
      end

      def health_check
        @healthy
      end
      
      private

      def break!
        @healthy = false
      end
      
    end

  end

end
