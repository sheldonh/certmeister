require 'spec_helper'

require 'certmeister/in_memory_store'

describe Certmeister::InMemoryStore do

  it "can be initialized with an existing data set" do
    existing = {'axl.hetzner.africa' => '...cert...'}
    store = Certmeister::InMemoryStore.new(existing)
    expect(store.fetch('axl.hetzner.africa')).to eql '...cert...'
  end

  it "stores certificates by CN (common name)" do
    pem = File.read('fixtures/client.crt')
    subject.store('axl.hetzner.africa', pem)
    expect(subject.fetch('axl.hetzner.africa')).to eql pem
  end

  it "returns nil when fetching non-existent CN" do
    expect(subject.fetch('axl.hetzner.africa')).to be_nil
  end

  it "is not concerned with validating certificates" do
    expect { subject.store('axl.hetzner.africa', "nonsense") }.to_not raise_error
  end

  it "overwrites an existing certificate if one exists" do
    subject.store('axl.hetzner.africa', "first")
    subject.store('axl.hetzner.africa', "second")
    expect(subject.fetch('axl.hetzner.africa')).to eql "second"
  end

  it "deletes certificates by CN (common name)" do
    subject.store('axl.hetzner.africa', "cert")
    expect(subject.remove('axl.hetzner.africa')).to be_true
    expect(subject.fetch('axl.hetzner.africa')).to be_nil
  end

  it "returns false when removing a non-existent CN" do
    expect(subject.remove('axl.hetzner.africa')).to be_false
  end

  it "returns true from health_check when healthy" do
    expect(subject.health_check).to be_true
  end

  it "returns false from health_check when not healthy" do
    subject.send(:break!)
    expect(subject.health_check).to be_false
  end

  describe "for use in testing" do

    it "store raises Certmeister::StoreError when broken" do
      subject.send(:break!)
      expect { subject.store('axl.hetzner.africa', "first") }.to raise_error(Certmeister::StoreError)
    end

    it "fetch raises Certmeister::StoreError when broken" do
      subject.send(:break!)
      expect { subject.fetch('axl.hetzner.africa') }.to raise_error(Certmeister::StoreError, "in-memory store is broken")
    end

    it "remove raises Certmeister::StoreError when broken" do
      subject.send(:break!)
      expect { subject.remove('axl.hetzner.africa') }.to raise_error(Certmeister::StoreError, "in-memory store is broken")
    end

  end

end

