require 'spec_helper'

require 'certmeister/policy/signature_algorithm'

describe Certmeister::Policy::SignatureAlgorithm do

	subject { Certmeister::Policy::SignatureAlgorithm.new(["sha256", "sha384", "sha512"]) }

	it "may be configured with a set of strong signature algorithms" do
		expect { Certmeister::Policy::SignatureAlgorithm.new([1,2])}.to raise_error(ArgumentError, "invalid set of signature algorithms") 
		expect { Certmeister::Policy::SignatureAlgorithm.new(["one", "two", "three"]) }.to_not raise_error
	end

  it "defaults to #{Certmeister::Policy::SignatureAlgorithm::DEFAULT_SIGNATURE_ALGORITHMS} as the set of strong signature algorithms" do
    expect(described_class.new.signature_algorithms).to eql Certmeister::Policy::SignatureAlgorithm::DEFAULT_SIGNATURE_ALGORITHMS
  end

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate a request with a missing pem" do
    response = subject.authenticate({anything: 'something'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing pem"
  end

  it "refuses to authenticate an invalid pem" do
    pem = "bad input"
    response = subject.authenticate({pem: pem})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "invalid pem (not enough data)"
  end

  it "refuses to authenticate a request with a weak signature algorithm" do  
    pem = File.read('fixtures/sha1_4096bit.csr')
    response = subject.authenticate({pem: pem})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "weak signature algorithm"
  end

    it "authenticates a request with a strong signature algorithm" do
    pem = File.read('fixtures/sha256_4096bit.csr')
    response = subject.authenticate({pem: pem})
    expect(response).to be_authenticated
  end

end
