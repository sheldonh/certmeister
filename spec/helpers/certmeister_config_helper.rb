module CertmeisterConfigHelper

  class ValidStore
    def store(cn, crt); end
    def fetch(cn); end
    def health_check(cn); end
  end

  def self.valid_config_options
    {ca_cert: 'fixtures/ca.crt', ca_key: 'fixtures/ca.key', store: ValidStore.new, authenticator: -> (request) {true} }
  end

  def self.valid_config
    Certmeister::Config.new(valid_config_options)
  end

end
