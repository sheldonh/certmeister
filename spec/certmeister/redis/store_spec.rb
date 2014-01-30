require 'spec_helper'
require 'certmeister/test/memory_store_interface'

require 'redis'
require 'certmeister/redis/store'

describe Certmeister::Redis::Store do

  class << self
    include Certmeister::Test::MemoryStoreInterface
  end

  let(:redis) { Redis.new }
  subject { Certmeister::Redis::Store.new(redis, "test") }

  it_behaves_like_a_certmeister_store

  private

  def redis_cleanup
    ["axl.starjuice.net", "axl.hetzner.africa"].each do |cn|
      redis.del(subject.send(:pem_key, "axl.hetzner.africa"))
    end
    leftovers = redis.keys("*")
    if !leftovers.empty?
      fail "redis keys not cleaned up: #{leftovers.inspect}"
    end
  end

  before(:each) do
    redis_cleanup
  end

  after(:each) do
    redis_cleanup
  end

end

