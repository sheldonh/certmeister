require 'spec_helper'

require 'certmeister/authenticator/fcrdns'

describe Certmeister::Authenticator::Fcrdns do

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate a request with a missing cn" do
    response = subject.authenticate({ip: '127.0.0.1'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing cn"
  end

  it "refuses to authenticate a request with a missing ip" do
    response = subject.authenticate({cn: 'localhost'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing ip"
  end

  it "refuses to authenticate a request with an ip that does not have fcrdns that matches the cn" do
    response = subject.authenticate({cn: 'bad.example.com', ip: '127.0.0.1'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "cn in unknown domain"
  end

  it "authenticates any request with an ip that does not have fcrdns that matches the cn" do
    response = subject.authenticate({cn: 'localhost', ip: '127.0.0.1'})
    expect(response).to be_authenticated
  end

  describe "error handling" do

    it "refuses to authenticate a request when a DNS failure occurs" do
      Resolv::DNS.any_instance.stub(:getnames).with('nonsense').and_raise(Resolv::ResolvError.new("cannot interpret as address: nonsense"))
      response = subject.authenticate({cn: 'localhost', ip: 'nonsense'})
      expect(response).to_not be_authenticated
      expect(response.error).to eql "DNS error (cannot interpret as address: nonsense)"
    end

  end

end
