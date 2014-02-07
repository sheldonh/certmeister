require 'spec_helper'
require 'certmeister/policy/blackhole'
require 'certmeister/policy/noop'

require 'certmeister/policy/chain_all'

describe Certmeister::Policy::ChainAll do

  it "must be configured with a list of policies" do
    expected_error = "enumerable collection of policies required"
    expect { Certmeister::Policy::ChainAll.new }.to raise_error(ArgumentError)
    expect { Certmeister::Policy::ChainAll.new(Certmeister::Policy::Noop.new) }.to raise_error(ArgumentError, expected_error)
    expect { Certmeister::Policy::ChainAll.new([]) }.to raise_error(ArgumentError, expected_error)
  end

  it "demands a request" do
    policy = Certmeister::Policy::ChainAll.new([Certmeister::Policy::Noop.new])
    expect { policy.authenticate }.to raise_error(ArgumentError)
  end

  it "authenticates a request that all its chained policies authenticate" do
    policy = Certmeister::Policy::ChainAll.new([Certmeister::Policy::Noop.new, Certmeister::Policy::Noop.new])
    response = policy.authenticate({anything: 'something'})
    expect(response).to be_authenticated
  end

  it "refuses a request that any one of its chained policies refuses" do
    refuse_last = Certmeister::Policy::ChainAll.new([ Certmeister::Policy::Noop.new, Certmeister::Policy::Blackhole.new])
    refuse_first = Certmeister::Policy::ChainAll.new([ Certmeister::Policy::Blackhole.new, Certmeister::Policy::Noop.new])
    policies = [refuse_last, refuse_first]

    policies.each do |policy|
      response = policy.authenticate({anything: 'something'})
      expect(response).to_not be_authenticated
    end
  end

  it "uses the error message of the first encountered refusal in the chain" do
    policy = Certmeister::Policy::ChainAll.new([
      Certmeister::Policy::Domain.new(['unmatched.com']),
      Certmeister::Policy::Blackhole.new,
    ])
    response = policy.authenticate({cn: 'wrongdomain.com'})
    expect(response.error).to eql 'cn in unknown domain'
  end

end

