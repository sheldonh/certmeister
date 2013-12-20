require 'spec_helper'
require 'certmeister/blackhole_authenticator'
require 'certmeister/noop_authenticator'

require 'certmeister/chain_all_authenticator'

describe Certmeister::ChainAllAuthenticator do

  it "must be configured with a list of authenticators" do
    expected_error = "enumerable collection of authenticators required"
    expect { Certmeister::ChainAllAuthenticator.new }.to raise_error(ArgumentError)
    expect { Certmeister::ChainAllAuthenticator.new(Certmeister::NoopAuthenticator.new) }.to raise_error(ArgumentError, expected_error)
    expect { Certmeister::ChainAllAuthenticator.new([]) }.to raise_error(ArgumentError, expected_error)
  end

  it "demands a request" do
    authenticator = Certmeister::ChainAllAuthenticator.new([Certmeister::NoopAuthenticator.new])
    expect { authenticator.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate an empty request" do
    authenticator = Certmeister::ChainAllAuthenticator.new([Certmeister::NoopAuthenticator.new])
    response = authenticator.authenticate({})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "empty request"
  end

  it "authenticates a request that all its chained authenticators authenticate" do
    authenticator = Certmeister::ChainAllAuthenticator.new([Certmeister::NoopAuthenticator.new, Certmeister::NoopAuthenticator.new])
    response = authenticator.authenticate({anything: 'something'})
    expect(response).to be_authenticated
  end

  it "refuses a request that any one of its chained authenticators refuses" do
    refuse_last = Certmeister::ChainAllAuthenticator.new([ Certmeister::NoopAuthenticator.new, Certmeister::BlackholeAuthenticator.new])
    refuse_first = Certmeister::ChainAllAuthenticator.new([ Certmeister::BlackholeAuthenticator.new, Certmeister::NoopAuthenticator.new])
    authenticators = [refuse_last, refuse_first]

    authenticators.each do |authenticator|
      response = authenticator.authenticate({anything: 'something'})
      expect(response).to_not be_authenticated
      expect(response.error).to eql "blackholed"
    end
  end

end

