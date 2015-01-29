require 'spec_helper'

require 'certmeister/policy/existing'
require 'certmeister/in_memory_store'

describe Certmeister::Policy::Existing do

  subject { Certmeister::Policy::Existing.new(Certmeister::InMemoryStore.new) }

  it "must be configured with access to the store" do
    expect { subject.class.new }.to raise_error(ArgumentError)
    expect { subject.class.new(Object.new) }.to raise_error(ArgumentError)
    expect { subject }.to_not raise_error
  end

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate a request with a missing cn" do
    response = subject.authenticate(cn: nil)
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing cn"
  end

  context "when the store contains a cert for axl.hetzner.africa" do

    subject { Certmeister::Policy::Existing.new(Certmeister::InMemoryStore.new({"axl.hetzner.africa" => "...cert..."})) }

    it "refuses to authenticate a request for axl.hetzner.africa" do
      response = subject.authenticate(cn: 'axl.hetzner.africa')
      expect(response).to_not be_authenticated
      expect(response.error).to match /exists/
    end

    it "authenticates requests for other common names" do
      response = subject.authenticate(cn: 'bob.example.com')
      expect(response).to be_authenticated
    end

  end



end
