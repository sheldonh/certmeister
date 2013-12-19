require 'spec_helper'
require 'helpers/certmeister_config_helper'
require 'helpers/certmeister_signing_request_helper'

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

    let(:valid_request) { CertmeisterSigningRequestHelper::valid_request }

    describe "refuses" do

      it "refuses the request if the authenticator declines it" do
        options = CertmeisterConfigHelper::valid_config_options
        options[:authenticator] = Certmeister::BlackholeAuthenticator.new
        ca = Certmeister.new(Certmeister::Config.new(options))
        response = ca.sign(valid_request)
        expect(response).to_not be_signed
        expect(response.error).to eql "request refused (blackholed)"
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

    end

    describe "signing" do

      def sign_valid_request
        ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
        ca.sign(valid_request)
      end

      it "signs a CSR if the authenticator passes the request" do
        response = sign_valid_request
        expect(response).to be_signed
      end

      it "sets the issuer to the subject of the CA certificate" do
        response = sign_valid_request
        cert = OpenSSL::X509::Certificate.new(response.pem)
        expect(cert.issuer.to_s).to match /CN=Certmeister Test CA/
      end

      it "sets the subject to the subject of the CSR" do
        response = sign_valid_request
        cert = OpenSSL::X509::Certificate.new(response.pem)
        expect(cert.subject.to_s).to match /CN=axl.hetzner.africa/
      end

      it "sets validity to 5 years from now" do
        now = (DateTime.now.to_time - 1)
        response = sign_valid_request
        cert = OpenSSL::X509::Certificate.new(response.pem)
        expect(cert.not_before).to be >= now
        expect(cert.not_after - cert.not_before).to be < (5 * 365 * 24 * 60 * 60 + 2)
        expect(cert.not_after - cert.not_before).to be >= (5 * 365 * 24 * 60 * 60)
      end

    end

  end

end

