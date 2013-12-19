require 'spec_helper'

require 'certmeister/response'

describe Certmeister::Response do

  let(:pem) { File.read('fixtures/client.crt') }

  describe "on error" do

    it "is not signed" do
      response = Certmeister::Response.new(nil, "something went wrong")
      expect(response).to_not be_signed
    end

    it "provides the error" do
      response = Certmeister::Response.new(nil, "something went wrong")
      expect(response.error).to eql "something went wrong"
    end

    it "doesn't provide the PEM-encoded X509 certificate as a string" do
      response = Certmeister::Response.new(pem, "something went wrong")
      expect(response.pem).to be_nil
    end

  end

  describe "on success" do

    it "is signed" do
      response = Certmeister::Response.new(pem, nil)
      expect(response).to be_signed
    end

    it "provides the PEM-encoded X509 certificate as a string" do
      response = Certmeister::Response.new(pem, nil)
      expect(response.pem).to eql pem
    end

    it "provides no error" do
      response = Certmeister::Response.new(pem, nil)
      expect(response.error).to be_nil
    end

  end

end
