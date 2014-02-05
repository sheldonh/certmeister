require 'certmeister/policy'

module Certmeister

  module Policy

    class ChainAll

      def initialize(policies)
        validate_policies(policies)
        @policies = policies
      end

      def authenticate(request)
        success = Certmeister::Policy::Response.new(true, nil)
        @policies.inject(success) do |continue, policy|
          response = policy.authenticate(request)
          break response unless response.authenticated?
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
