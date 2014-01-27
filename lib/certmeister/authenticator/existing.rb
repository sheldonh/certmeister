require 'certmeister/authenticator/response'

module Certmeister

  module Authenticator

    class Existing

      def initialize(store)
        is_a_store?(store) or raise ArgumentError.new("expected a fetchable store but received a #{store.class}")
        @store = store
      end

      def authenticate(request)
        if @store.fetch(request[:cn]).nil?
          Certmeister::Authenticator::Response.new(true, nil)
        else
          Certmeister::Authenticator::Response.new(false, "certificate for cn already exists")
        end
      end

      private

      def is_a_store?(store)
        store.respond_to?(:fetch)
      end

    end

  end

end
