require 'spec_helper'

require 'certmeister/authenticator/noop'

describe Certmeister::Authenticator::Noop do

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "authenticates any non-empty request" do
    response = subject.authenticate(anything: 'something')
    expect(response).to be_authenticated
    expect(response.error).to be_nil
  end

end
