require 'spec_helper'
require 'certmeister/test/memory_store_interface'

require 'certmeister/in_memory_store'

describe Certmeister::InMemoryStore do

  class << self
    include Certmeister::Test::MemoryStoreInterface
  end

  it_behaves_like_a_certmeister_store

  describe "for use in testing" do

    it "can be initialized with an existing data set" do
      existing = {'axl.hetzner.africa' => '...cert...'}
      store = Certmeister::InMemoryStore.new(existing)
      expect(store.fetch('axl.hetzner.africa')).to eql '...cert...'
    end

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

