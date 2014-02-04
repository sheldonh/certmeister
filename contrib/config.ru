require 'rubygems'
require 'rack'

require 'certmeister'
require 'certmeister/redis/store'
require 'certmeister/rack/app'
require 'redis'

allow = Certmeister::Policy::Noop.new

ca = Certmeister.new(
  Certmeister::Config.new(
    sign_policy: allow,
    fetch_policy: allow,
    remove_policy: allow,
    store: Certmeister::Redis::Store.new(Redis.new, "development"),
    ca_cert: File.read("../fixtures/ca.crt"),
    ca_key: File.read("../fixtures/ca.key"),
  )
)
certmeister = Certmeister::Rack::App.new(ca)

app = Rack::Builder.new do
  map "/ca" do
    run certmeister
  end
end

run app
