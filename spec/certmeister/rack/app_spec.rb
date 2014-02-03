require 'spec_helper'
require 'rack/test'

require 'certmeister'
require 'certmeister/rack/app'

describe Certmeister::Rack::App do

  include Rack::Test::Methods

  let(:response) { double(Certmeister::Response).as_null_object }
  let(:ca) { double(Certmeister::Base, sign: response) }
  let(:app) { Certmeister::Rack::App.new(ca) }

  it "GET /ping always PONGs (although one day we want a health check)" do
    get "/ping"
    expect(last_response.status).to eql 200
    expect(last_response.headers['Content-Type']).to eql "text/plain"
    expect(last_response.body).to eql "PONG"
  end

  it "/ping returns 405 Method Not Allowed for other HTTP verbs" do
    head "/ping"
    expect(last_response.status).to eql 405
    expect(last_response.headers['Content-Type']).to eql "text/plain"
    expect(last_response.body).to eql "405 Method Not Allowed"
  end

  it "returns 501 Not Implemented for an unknown URI" do
    get "/nonexistent"
    expect(last_response.status).to eql 501
    expect(last_response.headers['Content-Type']).to eql "text/plain"
    expect(last_response.body).to eql "501 Not Implemented"
  end

  describe "POST /certificate/:cn" do

    it "copies the cn into the params" do
      post "/certificate/axl.starjuice.net", {"csr" => "...csr..."}
      expect(ca).to have_received(:sign).with hash_including("cn" => "axl.starjuice.net")
    end

    it "copies the ip into the params" do
      post "/certificate/axl.starjuice.net", {"csr" => "...csr..."}, {"REMOTE_ADDR" => "192.168.1.2"}
      expect(ca).to have_received(:sign).with hash_including("ip" => "192.168.1.2")
    end

    it "passes the form params into the CA" do
      post "/certificate/axl.starjuice.net", {"csr" => "...csr..."}
      expect(ca).to have_received(:sign).with hash_including("csr" => "...csr...")
    end

    context "on hit" do

      let (:response) { Certmeister::Response.hit("...crt...") }

      before(:each) do
        post "/certificate/axl.starjuice.net", {"csr" => "...csr..."}
      end

      it "returns 303 See Other" do
        expect(last_response.status).to eql 303
      end

      it "offers the same resource URI as Location" do
        expect(last_response.headers['Location']).to eql "/certificate/axl.starjuice.net"
      end

      it "describes the HTTP status in the body" do
        expect(last_response.body).to eql '303 See Other'
      end

      it "describes the body as text/plain" do
        expect(last_response.headers['Content-Type']).to eql 'text/plain'
      end

    end

    context "on denied" do

      let (:response) { Certmeister::Response.denied("not enough mojo") }

      before(:each) do
        post "/certificate/axl.starjuice.net", {"csr" => "...csr..."}
      end

      it "returns 403 Forbidden" do
        expect(last_response.status).to eql 403
      end

      it "describes the HTTP status in the body" do
        expect(last_response.body).to eql '403 Forbidden (not enough mojo)'
      end

      it "describes the body as text/plain" do
        expect(last_response.headers['Content-Type']).to eql 'text/plain'
      end

    end

    context "on error" do

      let (:response) { Certmeister::Response.error("all is lost") }

      before(:each) do
        post "/certificate/axl.starjuice.net", {"csr" => "...csr..."}
      end

      it "returns 500 Internal Server Error" do
        expect(last_response.status).to eql 500
      end

      it "describes the HTTP status in the body" do
        expect(last_response.body).to eql "500 Internal Server Error (all is lost)"
      end

      it "describes the body as text/plain" do
        expect(last_response.headers['Content-Type']).to eql 'text/plain'
      end

    end

  end

end
