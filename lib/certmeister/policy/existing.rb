require 'certmeister/policy/response'

module Certmeister

  module Policy

    class Existing

      def initialize(store)
        is_a_store?(store) or raise ArgumentError.new("expected a fetchable store but received a #{store.class}")
        @store = store
      end

      def authenticate(request)
        if not request[:cn]
	  Certmeister::Policy::Response.new(false, "missing cn")
        elsif @store.fetch(request[:cn]).nil?
          Certmeister::Policy::Response.new(true, nil)
        else
          Certmeister::Policy::Response.new(false, "certificate for cn already exists")
        end
      end

      private

      def is_a_store?(store)
        store.respond_to?(:fetch)
      end

    end

  end

end
