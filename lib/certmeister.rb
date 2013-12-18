module Certmeister
end

require "certmeister/base"
require "certmeister/config"

module Certmeister

  def self.new(*args)
    Certmeister::Base.new(*args)
  end

end
