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
    [500, {'Content-Type' => 'text/plain'}, ["500 Internal Server Error (#{response.error})"]]
  elsif response.denied?
    [403, {'Content-Type' => 'text/plain'}, ["403 Forbidden (#{response.error})"]]
  else
    [303, {'Content-Type' => 'text/plain',
           'Location' => "/certificate/#{params[:cn]}"}, ["303 See Other"]]
  end
end

fetch_action = ->(params) do
  response = ca.fetch(params)
  if response.error?
    [500, {'Content-Type' => 'text/plain'}, ["500 Internal Server Error (#{response.error})"]]
  elsif response.denied?
    [403, {'Content-Type' => 'text/plain'}, ["403 Forbidden (#{response.error})"]]
  elsif response.miss?
    [404, {'Content-Type' => 'text/plain'}, ["404 Not Found"]]
  else
    [200, {'Content-Type' => 'application/x-pem-file'}, [response.pem]]
  end
end

remove_action = ->(params) do
  response = ca.remove(params)
  if response.error?
    [500, {'Content-Type' => 'text/plain'}, ["500 Internal Server Error (#{response.error})"]]
  elsif response.denied?
    [403, {'Content-Type' => 'text/plain'}, ["403 Forbidden (#{response.error})"]]
  elsif response.miss?
    [404, {'Content-Type' => 'text/plain'}, ["404 Not Found"]]
  else
    [200, {'Content-Type' => 'text/plain'}, ["200 OK"]]
  end
end

router = ->(env) do
  req = Rack::Request.new(env)
  if req.path_info =~ /^\/certificate\/(.+)/
    params = req.params.tap do |p|
      p[:cn] = $1
      p[:ip] = req.ip
    end
    case req.request_method
      when 'POST' then sign_action.call(params)
      when 'GET' then fetch_action.call(params)
      when 'DELETE' then remove_action.call(params)
      else [405, {'Content-Type' => 'text-plain'}, ["405 Method Not Allowed"]]
    end
  else
    [501, {'Content-Type' => 'text-plain'}, ["501 Not Implemented"]]
  end
end

run router
