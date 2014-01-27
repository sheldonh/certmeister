module Certmeister

  module Policy

    def self.validate_authenticate_signature(policy)
      policy and policy.respond_to?(:authenticate) and policy.method(:authenticate).arity == 1
    end

    def self.validate_authenticate_returns_response(policy)
      response = policy.authenticate({})
      response.respond_to?(:authenticated?) and response.respond_to?(:error)
    end

  end

end

Dir.glob(File.join(File.dirname(__FILE__), "policy", "*.rb")) do |path|
  require path
end

