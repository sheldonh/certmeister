require 'spec_helper'

require 'certmeister/policy/ip'
require 'ipaddr'

describe Certmeister::Policy::IP do

  subject { Certmeister::Policy::IP.new(['127.0.0.0/8', '192.168.0.0/23']) }

  it "demands a request" do
    expect { subject.authenticate }.to raise_error(ArgumentError)
  end

  it "explodes if initialized with things other than CIDR strings" do
    expect { Certmeister::Policy::IP.new(['localhost']) }.to raise_error(IPAddr::Error)
  end

  it "refuses to authenticate a request with a missing ip" do
    response = subject.authenticate(cn: 'localhost')
    expect(response).to_not be_authenticated
    expect(response.error).to eql "missing ip"
  end

  it "refuses to authenticate a request with a malformed ip" do
    response = subject.authenticate(cn: 'localhost', ip: '127.1')
    expect(response).to_not be_authenticated
    expect(response.error).to eql "invalid ip"
  end

  it "refuses to authenticate an IP outside the configured list of networks" do
    response = subject.authenticate(cn: 'localhost', ip: '172.16.0.1')
    expect(response).to_not be_authenticated
    expect(response.error).to eql "unauthorized ip"
  end

  it "allows an IP inside a configured network" do
    response = subject.authenticate(cn: 'localhost', ip: '192.168.0.1')
    expect(response).to be_authenticated
  end

end
