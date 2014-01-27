module Certmeister

  module Authenticator

    def self.validate_authenticate_signature(authenticator)
      authenticator and authenticator.respond_to?(:authenticate) and authenticator.method(:authenticate).arity == 1
    end

    def self.validate_authenticate_returns_response(authenticator)
      response = authenticator.authenticate({})
      response.respond_to?(:authenticated?) and response.respond_to?(:error)
    end

  end

end

Dir.glob(File.join(File.dirname(__FILE__), "authenticator", "*.rb")) do |path|
  require path
end

