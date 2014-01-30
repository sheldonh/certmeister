module Certmeister

  module Redis

    class Store

      def initialize(redis, environment = "development")
        @redis = redis
        @environment = environment
        @healthy = true
      end

      def store(cn, pem)
        @redis.set(pem_key(cn), pem)
      end

      def fetch(cn)
        @redis.get(pem_key(cn))
      end

      def remove(cn)
        num_removed = @redis.del(pem_key(cn))
        num_removed == 1
      end

      def health_check
        @healthy
      end
      
      private

      def pem_key(cn)
        "certmeister:#{@environment}:certificate:#{cn}"
      end

      def break!
        @healthy = false
      end
      
    end

  end

end
