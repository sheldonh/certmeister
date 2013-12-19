require 'spec_helper'
require 'helpers/certmeister_signing_request_helper'

require 'certmeister/blackhole_authenticator'

describe Certmeister::BlackholeAuthenticator do

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate an empty request" do
    response = subject.authenticate({})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "empty request"
  end

  it "refuses any request" do
    response = subject.authenticate(CertmeisterSigningRequestHelper::valid_request)
    expect(response).to_not be_authenticated
    expect(response.error).to eql "blackholed"
  end

end

