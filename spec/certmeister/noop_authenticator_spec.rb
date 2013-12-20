require 'spec_helper'

require 'certmeister/authenticator/noop'

describe Certmeister::Authenticator::Noop do

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate an empty request" do
    response = subject.authenticate({})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "empty request"
  end

  it "authenticates any non-empty request" do
    response = subject.authenticate(anything: 'something')
    expect(response).to be_authenticated
    expect(response.error).to be_nil
  end

end
