require 'spec_helper'

require 'certmeister/policy/fcrdns'

describe Certmeister::Policy::Fcrdns do

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate a request with a missing cn" do
    response = subject.authenticate({ip: '8.8.8.8'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing cn"
  end

  it "refuses to authenticate a request with a missing ip" do
    response = subject.authenticate({cn: 'google-public-dns-a.google.com'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing ip"
  end

  it "refuses to authenticate a request with an ip that does not have fcrdns that matches the cn" do
    response = subject.authenticate({cn: 'google-public-dns-a.google.com', ip: '127.0.0.1'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "cn does not match fcrdns"
  end

  it "authenticates any request with an ip that has fcrdns that matches the cn" do
    response = subject.authenticate({cn: 'google-public-dns-a.google.com', ip: '8.8.8.8'})
    expect(response).to be_authenticated
  end

  describe "error handling" do

    it "refuses to authenticate a request when a DNS failure occurs" do
      allow_any_instance_of(Resolv::DNS).to receive(:getnames).with('nonsense').and_raise(Resolv::ResolvError.new("cannot interpret as address: nonsense"))
      response = subject.authenticate({cn: 'localhost', ip: 'nonsense'})
      expect(response).to_not be_authenticated
      expect(response.error).to eql "DNS error (cannot interpret as address: nonsense)"
    end

  end

end
