require 'rubygems'
require 'rack'

require 'certmeister'
require 'certmeister/redis/store'
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

sign_action = ->(params) do
  response = ca.sign(params)
  if response.error?
    [500, {'Content-Type' => 'text/plain'}, [response.error]]
  else
    [303, {'Content-Type' => 'text/plain',
           'Location' => "/certificate/#{params[:cn]}"}, ["303 See Other"]]
  end
end

fetch_action = ->(params) do
  response = ca.fetch(params)
  if response.error?
    [500, {'Content-Type' => 'text/plain'}, [response.error]]
  elsif response.miss?
    [404, {'Content-Type' => 'text/plain'}, ["404 Object Not Found"]]
  else
    [200, {'Content-Type' => 'text/plain'}, [response.pem]]
  end
end

remove_action = ->(params) do
  response = ca.remove(params)
  if response.error?
    [500, {'Content-Type' => 'text/plain'}, [response.error]]
  elsif response.miss?
    [404, {'Content-Type' => 'text/plain'}, ["404 Object Not Found"]]
  else
    [200, {'Content-Type' => 'text/plain'}, ["200 OK"]]
  end
end

router = ->(env) do
  req = Rack::Request.new(env)
  if req.path_info =~ /^\/certificate\/(.+)/
    params = {
      cn: $1,
      ip: req.ip,
      csr: req.params['csr'],
    }
    case req.request_method
      when 'POST' then sign_action.call(params)
      when 'GET' then fetch_action.call(params)
      when 'DELETE' then remove_action.call(params)
      else [400, {'Content-Type' => 'text-plain'}, ["400 Unsupported operation #{req.request_method}"]]
    end
  else
    [400, {'Content-Type' => 'text-plain'}, ["404 Bad route #{req.path_info}"]]
  end
end

run router
