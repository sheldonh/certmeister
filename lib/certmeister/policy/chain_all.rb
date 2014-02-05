require 'certmeister/policy'

module Certmeister

  module Policy

    class ChainAll

      def initialize(policies)
        Certmeister::Policy.validate_policies(policies)
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

    end

  end

end
