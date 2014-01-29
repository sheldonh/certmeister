require 'spec_helper'

require 'certmeister/response'

describe Certmeister::Response do

  let(:pem) { File.read('fixtures/client.crt') }

  it "cannot be created with pem and error" do
    expect { Certmeister::Response.new(pem, "silly") }.to raise_error(ArgumentError)
  end

  describe "on error" do

    subject { Certmeister::Response.new(nil, "something went wrong") }

    it "provides the error" do
      expect(subject.error).to eql "something went wrong"
    end

    it "doesn't provide the PEM-encoded X509 certificate as a string" do
      expect(subject.pem).to be_nil
    end

    it "offers appropriate boolean flags" do
      expect(subject.hit?).to be_false
      expect(subject.miss?).to be_false
      expect(subject.error?).to be_true
    end

  end

  describe "on miss (i.e. not found)" do

    subject { Certmeister::Response.new(nil, nil) }

    it "has no error" do
      expect(subject.error).to be_nil
    end

    it "doesn't provide the PEM-encoded X509 certificate as a string" do
      expect(subject.pem).to be_nil
    end

    it "offers appropriate boolean flags" do
      expect(subject.hit?).to be_false
      expect(subject.miss?).to be_true
      expect(subject.error?).to be_false
    end

  end

  describe "on hit (success)" do

    subject { Certmeister::Response.new(pem, nil) }

    it "has no error" do
      expect(subject.error).to be_nil
    end

    it "provides the PEM-encoded X509 certificate as a string" do
      expect(subject.pem).to eql pem
    end

    it "offers appropriate boolean flags" do
      expect(subject.hit?).to be_true
      expect(subject.miss?).to be_false
      expect(subject.error?).to be_false
    end

  end

end
