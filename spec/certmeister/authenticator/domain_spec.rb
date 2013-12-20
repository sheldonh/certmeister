require 'spec_helper'

require 'certmeister/authenticator/domain'

describe Certmeister::Authenticator::Domain do

  subject { Certmeister::Authenticator::Domain.new(['hetzner.africa']) }

  it "must be configured with a list of domains" do
    expected_error = "enumerable collection of domains required"
    expect { Certmeister::Authenticator::Domain.new }.to raise_error(ArgumentError)
    expect { Certmeister::Authenticator::Domain.new('example.com') }.to raise_error(ArgumentError, expected_error)
    expect { Certmeister::Authenticator::Domain.new([]) }.to raise_error(ArgumentError, expected_error)
  end

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate an empty request" do
    response = subject.authenticate({})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "empty request"
  end

  it "refuses to authenticate a request with a missing cn" do
    response = subject.authenticate({anything: 'something'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing cn"
  end

  it "refuses to authenticate a request with a cn in an unknown domain" do
    response = subject.authenticate({anything: 'something', cn: 'axl.starjuice.net'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "cn in unknown domain"
  end

  it "authenticates any request with a cn in a known domain" do
    response = subject.authenticate({anything: 'something', cn: 'axl.hetzner.africa'})
    expect(response).to be_authenticated
  end


end
