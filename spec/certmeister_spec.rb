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
      options[:authenticator] = Certmeister::BlackholeAuthenticator.new
      ca = Certmeister.new(Certmeister::Config.new(options))
      response = ca.sign(valid_request)
      expect(response).to_not be_signed
      expect(response.error).to eql "request refused (blackholed)"
    end

    it "signs a CSR if the authenticator passes the request" do
      ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
      response = ca.sign(valid_request)
      expect(response).to be_signed
      cert = OpenSSL::X509::Certificate.new(response.pem)
      expect(cert.subject.to_s).to match /CN=axl.hetzner.africa/
      expect(cert.issuer.to_s).to match /CN=Certmeister Test CA/
    end

    it "refuses to sign an invalid CSR" do
      ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
      invalid_request = valid_request.tap { |r| r[:csr] = "a terrible misunderstanding" }
      response = ca.sign(invalid_request)
      expect(response).to_not be_signed
      expect(response.error).to eql "invalid CSR (not enough data)"
    end

    it "refuses to sign a CSR if the subject does not agree with the request CN" do
      request = valid_request.tap { |r| r[:cn] = "monkeyface.example.com" }
      ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
      response = ca.sign(request)
      expect(response).to_not be_signed
      expect(response.error).to eql "CSR subject (axl.hetzner.africa) disagrees with request CN (monkeyface.example.com)"
    end

    it "sets validity to 5 years from now" do
      now = (DateTime.now.to_time - 1)
      ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
      response = ca.sign(valid_request)
      cert = OpenSSL::X509::Certificate.new(response.pem)
      expect(cert.not_before).to be >= now
      expect(cert.not_after - cert.not_before).to be < (5 * 365 * 24 * 60 * 60 + 2)
      expect(cert.not_after - cert.not_before).to be >= (5 * 365 * 24 * 60 * 60)
    end

  end

end

