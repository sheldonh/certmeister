require 'spec_helper'

require 'certmeister/policy/noop'

describe Certmeister::Policy::Noop do

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "authenticates any non-empty request" do
    response = subject.authenticate(anything: 'something')
    expect(response).to be_authenticated
    expect(response.error).to be_nil
  end

end
