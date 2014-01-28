module CertmeisterFetchingRequestHelper

  def self.valid_request
    { cn: 'axl.hetzner.africa',
      ip: '127.0.0.1',
      psk: 'secret' }
  end

end
