require 'spec_helper'
require 'helpers/certmeister_config_helper'

require 'certmeister'

describe Certmeister::SelfTest do

  describe "#test(req = {cn: 'test', ip: '127.0.0.1'})" do

    context "when the CA is functioning correctly" do

      let(:ca) { Certmeister.new(CertmeisterConfigHelper::valid_config) }
      subject { Certmeister::SelfTest.new(ca) }

      it "returns success" do
        res = subject.test(cn: 'test', ip: '127.0.0.1')
        expect(res).to be_ok
      end

    end

    context "when the CA is malfunctioning" do

      let(:store) { Certmeister::InMemoryStore.new.tap { |o| o.send(:break!) } }
      let(:ca) { Certmeister.new(CertmeisterConfigHelper::custom_config(store: store)) }
      subject { Certmeister::SelfTest.new(ca) }

      it "returns an error" do
        res = subject.test(cn: 'test', ip: '127.0.0.1')
        expect(res).to_not be_ok
      end

      it "provides an error message in the response data" do
        res = subject.test(cn: 'test', ip: '127.0.0.1')
        expect(res.data[:message]).to match /in-memory store is broken/
      end

    end

  end

end
