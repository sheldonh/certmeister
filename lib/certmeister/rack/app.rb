require 'rack/request'

module Certmeister

  module Rack

    class App

      def initialize(ca)
        @ca = ca
      end

      def call(env)
        req = ::Rack::Request.new(env)
        if req.path_info == '/ping'
          if req.request_method == 'GET'
            [200, {'Content-Type' => 'text/plain'}, ['PONG']]
          else
            [405, {'Content-Type' => 'text/plain'}, ['405 Method Not Allowed']]
          end
        elsif req.path_info =~ %r{^/certificate/(.+)}
          params = req.params.tap do |p|
            p['cn'] = $1
            p['ip'] = req.ip
          end
          response = @ca.sign(params)
          if response.hit?
            [303, {'Content-Type' => 'text/plain', 'Location' => req.path_info}, ['303 See Other']]
          elsif response.denied?
            [403, {'Content-Type' => 'text/plain'}, ["403 Forbidden (#{response.error})"]]
          else
            [500, {'Content-Type' => 'text/plain'}, ["500 Internal Server Error (#{response.error})"]]
          end
        else
          [501, {'Content-Type' => 'text/plain'}, ['501 Not Implemented']]
        end
      end

    end

  end

end
