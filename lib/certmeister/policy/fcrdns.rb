require 'resolv'
require 'certmeister/policy/response'

module Certmeister

  module Policy

    class Fcrdns

      def authenticate(request)
        begin
          if not request[:cn]
            Certmeister::Policy::Response.new(false, "missing cn")
          elsif not request[:ip]
            Certmeister::Policy::Response.new(false, "missing ip")
          elsif not fcrdns_names(request[:ip]).include?(request[:cn])
            Certmeister::Policy::Response.new(false, "cn in unknown domain")
          else
            Certmeister::Policy::Response.new(true, nil)
          end
        rescue Resolv::ResolvError => e
          Certmeister::Policy::Response.new(false, "DNS error (#{e.message})")
        end
      end

      private

      def fcrdns_names(ip)
        resolv = Resolv::DNS.new
        names = resolv.getnames(ip)
        addresses = names.inject([]) { |m, name| m.concat(resolv.getaddresses(name)) }
        reverse_names = addresses.inject([]) { |m, address| m.concat(resolv.getnames(address.to_s)) }
        (names & reverse_names).map(&:to_s)
      end

    end

  end

end
