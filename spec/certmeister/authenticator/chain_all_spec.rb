require 'spec_helper'
require 'certmeister/authenticator/blackhole'
require 'certmeister/authenticator/noop'

require 'certmeister/authenticator/chain_all'

describe Certmeister::Authenticator::ChainAll do

  it "must be configured with a list of authenticators" do
    expected_error = "enumerable collection of authenticators required"
    expect { Certmeister::Authenticator::ChainAll.new }.to raise_error(ArgumentError)
    expect { Certmeister::Authenticator::ChainAll.new(Certmeister::Authenticator::Noop.new) }.to raise_error(ArgumentError, expected_error)
    expect { Certmeister::Authenticator::ChainAll.new([]) }.to raise_error(ArgumentError, expected_error)
  end

  it "demands a request" do
    authenticator = Certmeister::Authenticator::ChainAll.new([Certmeister::Authenticator::Noop.new])
    expect { authenticator.authenticate }.to raise_error(ArgumentError)
  end

  it "authenticates a request that all its chained authenticators authenticate" do
    authenticator = Certmeister::Authenticator::ChainAll.new([Certmeister::Authenticator::Noop.new, Certmeister::Authenticator::Noop.new])
    response = authenticator.authenticate({anything: 'something'})
    expect(response).to be_authenticated
  end

  it "refuses a request that any one of its chained authenticators refuses" do
    refuse_last = Certmeister::Authenticator::ChainAll.new([ Certmeister::Authenticator::Noop.new, Certmeister::Authenticator::Blackhole.new])
    refuse_first = Certmeister::Authenticator::ChainAll.new([ Certmeister::Authenticator::Blackhole.new, Certmeister::Authenticator::Noop.new])
    authenticators = [refuse_last, refuse_first]

    authenticators.each do |authenticator|
      response = authenticator.authenticate({anything: 'something'})
      expect(response).to_not be_authenticated
      expect(response.error).to eql "blackholed"
    end
  end

end

