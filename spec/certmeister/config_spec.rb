require 'spec_helper'
require 'helpers/certmeister_config_helper'
require 'helpers/certmeister_policy_helper'

require 'certmeister'

describe Certmeister::Config do

  let(:options) { CertmeisterConfigHelper::valid_config_options }

  def config_option_is_required(option)
    options.delete(option)
    config = Certmeister::Config.new(options)
    expect(config).to_not be_valid
    expect(config.errors[option]).to eql "is required"
  end

  def config_option_provides_method_with_arity(option, method, arity)
    arity_name = case arity
                 when 0 then "nullary"
                 when 1 then "unary"
                 when 2 then "binary"
                 when 3 then "ternary"
                 else
                   raise "broken test helper does not support arity #{4}"
                 end
    options[option].send(:define_singleton_method, method) { |wrong, number, of, arguments| }

    config = Certmeister::Config.new(options)
    expect(config).to_not be_valid
    expect(config.errors[option]).to eql "must provide a #{arity_name} #{method} method"
  end

  it "does not allow unknown options" do
    options[:unknown] = 1
    config = Certmeister::Config.new(options)
    expect(config).to_not be_valid
    expect(config.errors[:unknown]).to eql "is not a supported option"
  end

  describe ":ca_cert" do

    it "is required" do
      config_option_is_required(:ca_cert)
    end

    it "must be a PEM-encoded x509 certificate" do
      options[:ca_cert] = "-----BEGIN CERTIFICATE-----\n-----END CERTIFICATE-----\n"
      config = Certmeister::Config.new(options)
      expect(config).to_not be_valid
      expect(config.errors[:ca_cert]).to eql "must be a PEM-encoded x509 certificate (nested asn1 error)"
    end

    it "is accessible as an OpenSSL::X509::Certificate object" do
      config = Certmeister::Config.new(options)
      expect(config.ca_cert).to be_a(OpenSSL::X509::Certificate)
    end

  end

  describe ":ca_key" do

    it "is required" do
      config_option_is_required(:ca_key)
    end

    it "must be a string containing an x509 certificate in PEM encoding" do
      options[:ca_key] = "-----BEGIN RSA PRIVATE KEY-----\n-----END RSA PRIVATE KEY-----\n"
      config = Certmeister::Config.new(options)
      expect(config).to_not be_valid
      expect(config.errors[:ca_key]).to eql "must be a PEM-encoded private key (Could not parse PKey)"
    end

    it "is accessible as an OpenSSL::PKey::PKey object" do
      config = Certmeister::Config.new(options)
      expect(config.ca_key).to be_a(OpenSSL::PKey::PKey)
    end

  end

  describe ":store" do

    it "is required" do
      config_option_is_required(:store)
    end

    it "must provide a binary store method" do
      config_option_provides_method_with_arity(:store, :store, 2)
    end

    it "must provide a unary fetch method" do
      config_option_provides_method_with_arity(:store, :fetch, 1)
    end

    it "must provide a nullary health_check method" do
      config_option_provides_method_with_arity(:store, :health_check, 0)
    end

    it "is accessible" do
      config = Certmeister::Config.new(options)
      expect(config.store).to eql options[:store]
    end

  end

  describe ":policy" do

    it "is required" do
      config_option_is_required(:policy)
    end

    it "must provide a unary authenticate method" do
      config_option_provides_method_with_arity(:policy, :authenticate, 1)
    end

    it "must return a Certmeister::Policy::Response from the authenticate method" do
      options[:policy] = CertmeisterPolicyHelper::BrokenPolicy.new
      config = Certmeister::Config.new(options)
      expect(config).to_not be_valid
      expect(config.errors[:policy]).to eql "policy violates API"
    end

    it "is accessible" do
      config = Certmeister::Config.new(options)
      expect(config.policy).to eql options[:policy]
    end

  end

  describe "error_list" do

    it "is empty if the config has no errors" do
      config = Certmeister::Config.new(options)
      config.valid?
      expect(config.error_list).to be_empty
    end

    it "includes one string (option and message) per error if the config has errors" do
      options.delete(:ca_cert)
      options.delete(:ca_key)
      config = Certmeister::Config.new(options)
      config.valid?
      expect(config.error_list).to match_array ["ca_cert is required", "ca_key is required"]
    end

  end

  describe "openssl_digest" do

    it "causes a validation failure if the OpenSSL library doesn't provide one" do
      expect(OpenSSL::Digest).to receive(:const_defined?).twice.and_return(nil)
      config = Certmeister::Config.new(options)
      expect(config).to_not be_valid
      expect(config.errors[:openssl_digest]).to eql "can't find FIPS 140-2 compliant algorithm in OpenSSL::Digest"
    end

    it "is accessible without being supplied" do
      config = Certmeister::Config.new(options)
      expect([OpenSSL::Digest::SHA256, OpenSSL::Digest::SHA1]).to include(config.openssl_digest)
    end

  end

end
