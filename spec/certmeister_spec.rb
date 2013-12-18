require 'spec_helper'

require 'certmeister'

describe Certmeister::Config do

  describe "configuration" do

    class ValidStore
      def store(cn, crt); end
      def fetch(cn); end
      def health_check(cn); end
    end
    let(:options) { {ca_cert: 'fixtures/ca.crt', ca_key: 'fixtures/ca.key', store: ValidStore.new, authenticator: -> (request) {true} } }

    def config_option_is_required(option)
      options.delete(option)
      config = Certmeister::Config.new(options)
      expect(config).to_not be_valid
      expect(config.errors[option]).to eql "is required"
    end

    def config_option_must_name_existing_file(option)
      options[option] = "/nosuchfile"
      config = Certmeister::Config.new(options)
      expect(config).to_not be_valid
      expect(config.errors[option]).to eql "must name an existing file"
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

      it "must name an existing CA certificate file" do
        config_option_must_name_existing_file(:ca_cert)
      end

      it "is accessible" do
        config = Certmeister::Config.new(options)
        expect(config.ca_cert).to eql options[:ca_cert]
      end

    end

    describe ":ca_key" do

      it "is required" do
        config_option_is_required(:ca_key)
      end

      it "must name an existing CA key file" do
        config_option_must_name_existing_file(:ca_key)
      end

      it "is accessible" do
        config = Certmeister::Config.new(options)
        expect(config.ca_key).to eql options[:ca_key]
      end

    end

    describe ":store" do

      it "is required" do
        config_option_is_required(:store)
      end

      it "must provide a binary store method" do
        options[:store].send(:define_singleton_method, :store) { |wrong, number, of, arguments| }

        config = Certmeister::Config.new(options)
        expect(config).to_not be_valid
        expect(config.errors[:store]).to eql "must provide a binary store method"
      end

      it "must provide a unary fetch method" do
        options[:store].send(:define_singleton_method, :fetch) { |wrong, number, of, arguments| }

        config = Certmeister::Config.new(options)
        expect(config).to_not be_valid
        expect(config.errors[:store]).to eql "must provide a unary fetch method"
      end

      it "must provide a nullary health_check method" do
        options[:store].send(:define_singleton_method, :health_check) { |wrong, number, of, arguments| }

        config = Certmeister::Config.new(options)
        expect(config).to_not be_valid
        expect(config.errors[:store]).to eql "must provide a nullary health_check method"
      end

      it "is accessible" do
        config = Certmeister::Config.new(options)
        expect(config.store).to eql options[:store]
      end

    end

    describe ":authenticator" do

      it "is optional" do
        config = Certmeister::Config.new(options)
        expect(config).to be_valid

        options.delete(:authenticator)
        config = Certmeister::Config.new(options)
        expect(config).to be_valid
      end

      it "must provide a unary callable if given" do
        options[:authenticator] = -> {:bad_arity}
        config = Certmeister::Config.new(options)
        expect(config).to_not be_valid
        expect(config.errors[:authenticator]).to eql "must be a unary callable if given"
      end

      it "is accessible" do
        config = Certmeister::Config.new(options)
        expect(config.authenticator).to eql options[:authenticator]
      end

    end

  end

end
