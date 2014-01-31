require 'certmeister/policy/response'
require 'ipaddr'

module Certmeister

  module Policy

    class IP

      def initialize(networks)
        @networks = networks.map { |n| IPAddr.new(n) }
      end

      def authenticate(request)
        begin
          if !request[:ip]
            Certmeister::Policy::Response.new(false, "missing ip")
          else
            ip = IPAddr.new(request[:ip])
            if @networks.any? { |n| n.include?(ip) }
              Certmeister::Policy::Response.new(true, nil)
            else
              Certmeister::Policy::Response.new(false, "unauthorized ip")
            end
          end
        rescue IPAddr::Error
          Certmeister::Policy::Response.new(false, "invalid ip")
        end
      end

    end

  end

end
