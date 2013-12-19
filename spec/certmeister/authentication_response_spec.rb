require 'spec_helper'

require 'certmeister/authentication_response'

describe Certmeister::AuthenticationResponse do

  describe "on error" do

    it "is not authenticated" do
      response = Certmeister::AuthenticationResponse.new(nil, "you smell wrong")
      expect(response).to_not be_authenticated
    end

    it "provides the error" do
      response = Certmeister::AuthenticationResponse.new(nil, "you smell wrong")
      expect(response.error).to eql "you smell wrong"
    end

  end

  describe "on success" do

    it "is authenticated" do
      response = Certmeister::AuthenticationResponse.new(true, nil)
      expect(response).to be_authenticated
    end

    it "provides no error" do
      response = Certmeister::AuthenticationResponse.new(true, nil)
      expect(response.error).to be_nil
    end

  end

end
