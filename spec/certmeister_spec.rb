require 'spec_helper'
require 'helpers/certmeister_config_helper'

require 'certmeister'

describe Certmeister do

  it "is configured at instantiation" do
    expect { Certmeister.new(CertmeisterConfigHelper::valid_config) }.to_not raise_error
  end

  it "cannot be instantiated with an invalid config" do
    expect { Certmeister.new(Certmeister::Config.new({})) }.to raise_error(RuntimeError, /invalid config/)
  end

end

