require 'spec_helper'

require 'certmeister/fetching_response'

describe Certmeister::FetchingResponse do

  let(:pem) { File.read('fixtures/client.crt') }

  describe "on error" do

    it "is not fetched" do
      response = Certmeister::FetchingResponse.new(nil, "something went wrong")
      expect(response).to_not be_fetched
    end

    it "provides the error" do
      response = Certmeister::FetchingResponse.new(nil, "something went wrong")
      expect(response.error).to eql "something went wrong"
    end

    it "doesn't provide the PEM-encoded X509 certificate as a string" do
      response = Certmeister::FetchingResponse.new(pem, "something went wrong")
      expect(response.pem).to be_nil
    end

  end

  describe "on success" do

    it "is fetched" do
      response = Certmeister::FetchingResponse.new(pem, nil)
      expect(response).to be_fetched
    end

    it "provides the PEM-encoded X509 certificate as a string" do
      response = Certmeister::FetchingResponse.new(pem, nil)
      expect(response.pem).to eql pem
    end

    it "provides no error" do
      response = Certmeister::FetchingResponse.new(pem, nil)
      expect(response.error).to be_nil
    end

  end

end
