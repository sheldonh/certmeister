require 'certmeister/policy/response'
require 'openssl'

module Certmeister

	module Policy

		class SignatureAlgorithm

			DEFAULT_SIGNATURE_ALGORITHMS = ["sha256", "sha384", "sha512"]

			attr_reader :signature_algorithms
      
   
  			def initialize(signature_algorithms = DEFAULT_SIGNATURE_ALGORITHMS)
    			validate_signature_algorithms(signature_algorithms)
        		@signature_algorithms = signature_algorithms
    		end

        def authenticate(request)
          if not request[:pem]
            Certmeister::Policy::Response.new(false, "missing pem")
          else
            cert = OpenSSL::X509::Request.new(request[:pem])
            signature_algorithm = cert.signature_algorithm
            if signature_algorithm.include? "WithRSAEncryption"
              signature_algorithm = signature_algorithm.sub("WithRSAEncryption", "")
            else
              Certmeister::Policy::Response.new(false, "unknown/unsupported signature algorithm")
            end              
            if @signature_algorithms.include? signature_algorithm
              Certmeister::Policy::Response.new(true, nil)
            else
              Certmeister::Policy::Response.new(false, "weak signature algorithm")
            end
        end
        rescue OpenSSL::X509::RequestError => e
          Certmeister::Policy::Response.new(false, "invalid pem (#{e.message})")
        end

  			private

  			def validate_signature_algorithms(signature_algorithms)
  				unless signature_algorithms.kind_of?(Array)
  					raise ArgumentError.new("invalid set of signature algorithms")
  				end
  				signature_algorithms.each do |element|
  					unless element.kind_of?(String)
						raise ArgumentError.new("invalid set of signature algorithms")
					end
				end

			end

		end

	end

end
