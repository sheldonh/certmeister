module Certmeister

  class SelfTest

    # Pass in PEM-encoded key for fast tests that don't need lots of entropy.
    def initialize(ca, key = nil)
      @ca = ca
      @key = key
    end

    def test(req = {cn: 'test', ip: '127.0.0.1'})
      begin
        test!(req = {cn: 'test', ip: '127.0.0.1'})
        Result.new(true, {message: "OK"})
      rescue Exception => e
        Result.new(false, {message: e.message})
      end
    end

    def test!(req = {cn: 'test', ip: '127.0.0.1'})
      res = @ca.remove(req)
      res.hit? or res.miss? or raise "Test certificate remove failed: #{res.error}"

      csr = get_csr("C=ZA, ST=Western Cape, L=Cape Town, O=Hetzner PTY Ltd, CN=#{req[:cn]}")
      res = @ca.sign(cn: 'test', csr: csr.to_pem, ip: '127.0.0.1')
      res.hit? or raise "Test certificate signing failed: #{res.error}"

      res = @ca.fetch(cn: 'test', ip: '127.0.0.1')
      res.hit? or raise "Test certificate fetch failed: #{res.error}"

      cert = OpenSSL::X509::Certificate.new(res.pem)
      cert.subject.to_s =~ /CN=#{req[:cn]}/ or raise "Test certificate common name mismatch"

      nil
    end

    private

    def get_csr(subject)
      key = get_key
      csr = OpenSSL::X509::Request.new
      csr.version = 0
      csr.subject = OpenSSL::X509::Name.parse(subject)
      csr.public_key = key.public_key
      csr.sign key, OpenSSL::Digest::SHA256.new
      csr
    end

    def get_key
      OpenSSL::PKey::RSA.new(@key || 4096).tap do |key|
        @key ||= key.to_pem
      end
    end

    class Result
      attr_reader :data

      def initialize(ok, data)
        @ok = !!ok
        @data = data
      end

      def ok?
        @ok
      end

      def message
        @data.fetch(:message, nil) if @data.respond_to?(:fetch)
      end

    end

  end

end
