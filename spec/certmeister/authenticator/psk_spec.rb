require 'spec_helper'

require 'certmeister/authenticator/psk'

describe Certmeister::Authenticator::Psk do

  subject { Certmeister::Authenticator::Psk.new(['secret']) }

  it "must be configured with a list of psks" do
    expected_error = "enumerable collection of psks required"
    expect { Certmeister::Authenticator::Psk.new }.to raise_error(ArgumentError)
    expect { Certmeister::Authenticator::Psk.new('secret') }.to raise_error(ArgumentError, expected_error)
    expect { Certmeister::Authenticator::Psk.new([]) }.to raise_error(ArgumentError, expected_error)
  end

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate an empty request" do
    response = subject.authenticate({})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "empty request"
  end

  it "refuses to authenticate a request with a missing psk" do
    response = subject.authenticate({anything: 'something'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing psk"
  end

  it "refuses to authenticate a request with an unknown psk" do
    response = subject.authenticate({anything: 'something', psk: 'wrong'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "unknown psk"
  end

  it "authenticates any request with a known psk" do
    response = subject.authenticate({anything: 'something', psk: 'secret'})
    expect(response).to be_authenticated
  end


end
