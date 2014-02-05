module Certmeister

  module Policy

    def self.validate_authenticate_signature(policy)
      policy and policy.respond_to?(:authenticate) and policy.method(:authenticate).arity == 1
    end

    def self.validate_authenticate_returns_response(policy)
      response = policy.authenticate({})
      response.respond_to?(:authenticated?) and response.respond_to?(:error)
    end

    def self.validate_policies(policies)
      unless policies.is_a?(Enumerable) and policies.respond_to?(:size) and policies.size > 0 and
          policies.all? { |policy| self.validate_authenticate_signature(policy) }
        raise ArgumentError.new("enumerable collection of policies required")
      end
    end

  end

end

Dir.glob(File.join(File.dirname(__FILE__), "policy", "*.rb")) do |path|
  require path
end

