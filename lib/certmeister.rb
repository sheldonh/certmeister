module Certmeister
end

Dir.glob(File.join(File.dirname(__FILE__), "certmeister", "*.rb")) do |path|
  require path
end

module Certmeister

  def self.new(*args)
    Certmeister::Base.new(*args)
  end

end
