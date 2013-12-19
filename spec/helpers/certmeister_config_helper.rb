require 'certmeister/in_memory_store'
require 'certmeister/noop_authenticator'

module CertmeisterConfigHelper

  def self.valid_config_options
    ca_cert = File.read('fixtures/ca.crt')
    ca_key = File.read('fixtures/ca.key')
    {ca_cert: ca_cert, ca_key: ca_key, store: Certmeister::InMemoryStore.new, authenticator: Certmeister::NoopAuthenticator.new }
  end

  def self.valid_config
    Certmeister::Config.new(valid_config_options)
  end

end
