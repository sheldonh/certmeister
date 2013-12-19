require 'spec_helper'
require 'helpers/certmeister_config_helper'

require 'certmeister'
require 'openssl'

describe Certmeister do

  it "is configured at instantiation" do
    expect { Certmeister.new(CertmeisterConfigHelper::valid_config) }.to_not raise_error
  end

  it "cannot be instantiated with an invalid config" do
    expect { Certmeister.new(Certmeister::Config.new({})) }.to raise_error(RuntimeError, /invalid config/)
  end

  describe "#sign(request)" do

    let(:valid_request) { {cn: 'axl.hetzner.africa', ip: '127.0.0.1', csr: File.read('fixtures/client.csr'), psk: 'secret'} }

    it "refuses the request if the authenticator declines it" do
      options = CertmeisterConfigHelper::valid_config_options
      options[:authenticator] = -> (request) { false }
      ca = Certmeister.new(Certmeister::Config.new(options))
      pem = ca.sign(valid_request)
      expect(pem).to be_nil
    end

    it "signs a CSR if the authenticator passes the request" do
      ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
      pem = ca.sign(valid_request)
      cert = OpenSSL::X509::Certificate.new(pem)
      expect(cert.subject.to_s).to match /CN=axl.hetzner.africa/
      expect(cert.issuer.to_s).to match /CN=Certmeister Test CA/
    end

    it "does what when the CSR PEM is invalid?"

    it "does what if the request cn does not match the subject of the CSR?"

    it "sets the certificate 'not after' to when?"

  end

end

