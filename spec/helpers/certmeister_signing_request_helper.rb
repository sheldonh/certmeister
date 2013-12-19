module CertmeisterSigningRequestHelper

  def self.valid_request
    {cn: 'axl.hetzner.africa', ip: '127.0.0.1', csr: File.read('fixtures/client.csr'), psk: 'secret'}
  end

end
