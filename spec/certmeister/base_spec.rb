require 'spec_helper'
require 'helpers/certmeister_config_helper'
require 'helpers/certmeister_signing_request_helper'
require 'helpers/certmeister_fetching_request_helper'

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

      it "refuses the request if it has no cn" do
        ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
        invalid_request = valid_request.tap { |o| o.delete(:cn) }
        response = ca.sign(invalid_request)
        expect(response).to_not be_signed
        expect(response.error).to match /CN/
      end

      it "refuses the request if the sign policy declines it" do
        options = CertmeisterConfigHelper::valid_config_options
        options[:sign_policy] = Certmeister::Policy::Blackhole.new
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

      it "signs a CSR if the sign policy passes the request" do
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

      it "stores the signed certificate, indexed on request CN" do
        config = CertmeisterConfigHelper::valid_config
        ca = Certmeister.new(config)
        response = ca.sign(valid_request)
        stored = config.store.fetch('axl.hetzner.africa')
        expect(stored).to eql response.pem
      end

      it "does not capture errors from the store" do
        config = CertmeisterConfigHelper::valid_config
        config.store.send(:break!)
        ca = Certmeister.new(config)
        expect { ca.sign(valid_request) }.to raise_error(Certmeister::StoreError)
      end

    end

  end

  describe "#fetch(request)" do

    let(:valid_request) { CertmeisterFetchingRequestHelper::valid_request }

    describe "refuses" do

      it "refuses the request if it has no cn" do
        ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
        invalid_request = valid_request.tap { |o| o.delete(:cn) }
        response = ca.fetch(invalid_request)
        expect(response).to_not be_fetched
        expect(response.error).to match /CN/
      end

    end
    
    it "returns nil if the store has no certificate for the cn" do
      ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
      expect(ca.fetch(cn: 'axl.starjuice.net')).to be_nil
    end

    it "returns the certificate as a PEM-encoded string when the store has a certificate for the cn" do
      config = CertmeisterConfigHelper::valid_config
      config.store.store('axl.starjuice.net', '...')
      ca = Certmeister.new(config)
      expect(ca.fetch(cn: 'axl.starjuice.net')).to eql '...'
    end

    class StoreWithBrokenFetch
      def store(cn, cert); end
      def fetch(cn); raise Certmeister::StoreError.new("simulated error"); end
      def health_check; end
    end

    it "does not capture errors from the store" do
      config = CertmeisterConfigHelper::valid_config
      config.store.send(:break!)
      ca = Certmeister.new(config)
      expect { ca.fetch(cn: 'axl.starjuice.net') }.to raise_error(Certmeister::StoreError)
    end

  end

  describe "#remove(cn)" do

    it "returns true is the certificate existed in the store" do
      config = CertmeisterConfigHelper::valid_config
      config.store.store('axl.starjuice.net', '...')
      ca = Certmeister.new(config)
      expect(ca.remove('axl.starjuice.net')).to eql true
    end

    it "returns false if the certificate did not exist in the store" do
      ca = Certmeister.new(CertmeisterConfigHelper::valid_config)
      expect(ca.remove('axl.starjuice.net')).to be_false
    end

    it "removes the certificate from the store" do
      config = CertmeisterConfigHelper::valid_config
      config.store.store('axl.starjuice.net', '...')
      ca = Certmeister.new(config)
      ca.remove('axl.starjuice.net')
      expect(config.store.fetch('axl.starjuice.net')).to be_nil
    end

    it "does not capture errors from the store" do
      config = CertmeisterConfigHelper::valid_config
      config.store.send(:break!)
      ca = Certmeister.new(config)
      expect { ca.remove('axl.starjuice.net') }.to raise_error(Certmeister::StoreError)
    end

  end

end

