require 'certmeister/policy'

module Certmeister

  module Policy

    class ChainAny

      def initialize(policies)
        Certmeister::Policy.validate_policies(policies)
        @policies = policies
      end

      def authenticate(request)
        @policies.inject(nil) do |continue, policy|
          response = policy.authenticate(request)
          break response if response.authenticated?
          continue or response
        end
      end

    end

  end

end
