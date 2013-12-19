# Inspired by https://gist.github.com/mitfik/1922961

require 'openssl'
require 'time'

if OpenSSL::Digest.const_defined?('SHA256')
  @digest = OpenSSL::Digest::SHA256
elsif OpenSSL::Digest.const_defined?('SHA1')
  @digest = OpenSSL::Digest::SHA1
else
  raise "No FIPS 140-2 compliant digest algorithm in OpenSSL::Digest"
end

ca_cert_data = File.read('fixtures/ca.crt')
ca_key_data = File.read('fixtures/ca.key')

ca_cert = OpenSSL::X509::Certificate.new(ca_cert_data)
ca_key = OpenSSL::PKey.read(ca_key_data)
puts "# CA cert"
puts ca_cert.to_pem

csr_data = File.read('fixtures/client.csr')
csr = OpenSSL::X509::Request.new(csr_data)
puts "# client certificate signing request"
puts csr.to_pem

now = DateTime.now
cert = OpenSSL::X509::Certificate.new
cert.serial = 0
cert.version = 2
cert.not_before = now.to_time
cert.not_after = (now + (5 * 365)).to_time
cert.subject = csr.subject
cert.public_key = csr.public_key
cert.issuer = ca_cert.subject
cert.sign ca_key, @digest.new

puts "# client certificate"
puts cert.to_pem
