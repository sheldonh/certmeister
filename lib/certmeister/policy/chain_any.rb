require 'certmeister/policy'

module Certmeister

  module Policy

    class ChainAny

      def initialize(policies)
        Certmeister::Policy.validate_policies(policies)
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

    end

  end

end
