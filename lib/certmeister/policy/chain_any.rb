require 'certmeister/policy'

module Certmeister

  module Policy

    class ChainAll

      def initialize(policys)
        validate_policys(policys)
        @policys = policys
      end

      def authenticate(request)
        success = Certmeister::Policy::Response.new(true, nil)
        @policys.inject(success) do |continue, policy|
          response = policy.authenticate(request)
          break response unless response.authenticated?
          continue
        end
      end

      private

      def validate_policys(policys)
        unless policys.is_a?(Enumerable) and policys.respond_to?(:size) and policys.size > 0 and
               policys.all? { |policy| Certmeister::Policy.validate_authenticate_signature(policy) }
          raise ArgumentError.new("enumerable collection of policys required")
        end
      end

    end

  end

end
