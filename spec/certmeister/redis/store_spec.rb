require 'spec_helper'
require 'certmeister/test/memory_store_interface'

require 'certmeister/redis/store'

describe Certmeister::Redis::Store do

  class << self
    include Certmeister::Test::MemoryStoreInterface
  end

  subject { Certmeister::Redis::Store.new(double("Redis")) }
  
  it_behaves_like_a_certmeister_store

end

