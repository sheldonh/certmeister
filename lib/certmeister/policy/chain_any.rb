require 'certmeister/policy'

module Certmeister

  module Policy

    class ChainAny

      def initialize(policies)
        validate_policies(policies)
        @policies = policies
      end

      def authenticate(request)
        failure = Certmeister::Policy::Response.new(false, "no conditions satisifed")
        @policies.inject(failure) do |continue, policy|
          response = policy.authenticate(request)
          break response if response.authenticated?
          continue
        end
      end

      private

      def validate_policies(policies)
        unless policies.is_a?(Enumerable) and policies.respond_to?(:size) and policies.size > 0 and
               policies.all? { |policy| Certmeister::Policy.validate_authenticate_signature(policy) }
          raise ArgumentError.new("enumerable collection of policies required")
        end
      end

    end

  end

end
