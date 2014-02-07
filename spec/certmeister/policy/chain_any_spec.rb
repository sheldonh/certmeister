require 'spec_helper'
require 'certmeister/policy/blackhole'
require 'certmeister/policy/noop'

require 'certmeister/policy/chain_any'

describe Certmeister::Policy::ChainAny do

  it "must be configured with a list of policies" do
    expected_error = "enumerable collection of policies required"
    expect { Certmeister::Policy::ChainAny.new }.to raise_error(ArgumentError)
    expect { Certmeister::Policy::ChainAny.new(Certmeister::Policy::Noop.new) }.to raise_error(ArgumentError, expected_error)
    expect { Certmeister::Policy::ChainAny.new([]) }.to raise_error(ArgumentError, expected_error)
  end

  it "demands a request" do
    policy = Certmeister::Policy::ChainAny.new([Certmeister::Policy::Noop.new])
    expect { policy.authenticate }.to raise_error(ArgumentError)
  end

  it "authenticates a request that any of its chained policies authenticate" do
    policy = Certmeister::Policy::ChainAny.new([Certmeister::Policy::Blackhole.new, Certmeister::Policy::Noop.new, Certmeister::Policy::Blackhole.new])
    response = policy.authenticate({anything: 'something'})
    expect(response).to be_authenticated
  end

  it "refuses a request that none of its chained policies refuses" do
    policy = Certmeister::Policy::ChainAny.new([ Certmeister::Policy::Blackhole.new, Certmeister::Policy::Blackhole.new])
    response = policy.authenticate({anything: 'something'})
    expect(response).to_not be_authenticated
  end

  it "uses the error message of the first encountered refusal in the chain" do
    policy = Certmeister::Policy::ChainAny.new([
      Certmeister::Policy::Domain.new(['unmatched.com']),
      Certmeister::Policy::Blackhole.new,
    ])
    response = policy.authenticate({cn: 'wrongdomain.com'})
    expect(response.error).to eql 'cn in unknown domain'
  end

end

