require 'spec_helper'

require 'certmeister/response'

describe Certmeister::Response do

  let(:pem) { File.read('fixtures/client.crt') }

  it "must be instantiated via the factory methods only" do
    expect { Certmeister::Response.new(pem, nil, nil) }.to raise_error(NoMethodError, /private/)
  end

  describe "on error" do

    subject { Certmeister::Response.error("something went wrong") }

    it "provides the error" do
      expect(subject.error).to eql "something went wrong"
    end

    it "doesn't provide the PEM-encoded X509 certificate as a string" do
      expect(subject.pem).to be_nil
    end

    it "offers appropriate boolean flags" do
      expect(subject.hit?).to be false
      expect(subject.miss?).to be false
      expect(subject.denied?).to be false
      expect(subject.error?).to be true
    end

  end

  describe "on denial" do

    subject { Certmeister::Response.denied("bad client, no cookie") }

    it "provides the reason" do
      expect(subject.error).to eql "bad client, no cookie"
    end

    it "doesn't provide the PEM-encoded X509 certificate as a string" do
      expect(subject.pem).to be_nil
    end

    it "offers appropriate boolean flags" do
      expect(subject.hit?).to be false
      expect(subject.miss?).to be false
      expect(subject.denied?).to be true
      expect(subject.error?).to be false
    end

  end

  describe "on miss (i.e. not found)" do

    subject { Certmeister::Response.miss }

    it "has no error" do
      expect(subject.error).to be_nil
    end

    it "doesn't provide the PEM-encoded X509 certificate as a string" do
      expect(subject.pem).to be_nil
    end

    it "offers appropriate boolean flags" do
      expect(subject.hit?).to be false
      expect(subject.miss?).to be true
      expect(subject.denied?).to be false
      expect(subject.error?).to be false
    end

  end

  describe "on hit (success)" do

    subject { Certmeister::Response.hit(pem) }

    it "has no error" do
      expect(subject.error).to be_nil
    end

    it "provides the PEM-encoded X509 certificate as a string (or :none)" do
      # some hits, like the one for a remove(), don't have a pem, returning :none
      expect(subject.pem).to eql pem
    end

    it "offers appropriate boolean flags" do
      expect(subject.hit?).to be true
      expect(subject.miss?).to be false
      expect(subject.denied?).to be false
      expect(subject.error?).to be false
    end

  end

end
