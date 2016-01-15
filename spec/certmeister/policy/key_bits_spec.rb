require 'spec_helper'

require 'certmeister/policy/key_bits'

describe Certmeister::Policy::KeyBits do

  subject { Certmeister::Policy::KeyBits.new(4096) }

  it "may be configured with a minimum key size in bits" do
    expect { Certmeister::Policy::KeyBits.new("hamster") }.to raise_error(ArgumentError, "invalid minimum key size")
    expect { Certmeister::Policy::KeyBits.new(4096) }.to_not raise_error
  end

  it "defaults to #{Certmeister::Policy::KeyBits::DEFAULT_MIN_KEY_BITS} bits minimum key size" do
    expect(described_class.new.min_key_bits).to eql Certmeister::Policy::KeyBits::DEFAULT_MIN_KEY_BITS
  end

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "refuses to authenticate a request with a missing csr" do
    response = subject.authenticate({anything: 'something'})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing csr"
  end

  it "refuses to authenticate an invalid csr" do
    pem = "bad input"
    response = subject.authenticate({csr: pem})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "invalid csr (not enough data)"
  end

  it "refuses to authenticate a request for a key with too few bits" do
    pem = File.read('fixtures/sha256_1024bit.csr')
    response = subject.authenticate({csr: pem})
    expect(response).to_not be_authenticated
    expect(response.error).to eql "weak key"
  end

  it "authenticates a request for a key with sufficient bits" do
    pem = File.read('fixtures/sha256_4096bit.csr')
    response = subject.authenticate({csr: pem})
    expect(response).to be_authenticated
  end

end
