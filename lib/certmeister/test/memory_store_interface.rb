module Certmeister

  module Test
    
    module MemoryStoreInterface

      def it_behaves_like_a_certmeister_store
        
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
          expect(subject.remove('axl.hetzner.africa')).to be true
          expect(subject.fetch('axl.hetzner.africa')).to be_nil
        end

        it "is enumerable" do
          expect(subject).to be_a(Enumerable)
        end

        it "iterates certificates by cn" do
          subject.store('axl.hetzner.africa', "hetzner-cert")
          subject.store('axl.starjuice.net', "hetzner-cert")
          received = {}
          subject.each do |cn, cert|
            expect(received).to_not include(cn)
            received[cn] = cert
          end
          expect(received).to eql({'axl.hetzner.africa' => "hetzner-cert", 'axl.starjuice.net' => "hetzner-cert"})
        end

        it "returns false when removing a non-existent CN" do
          expect(subject.remove('axl.hetzner.africa')).to be false
        end

        it "returns true from health_check when healthy" do
          expect(subject.health_check).to be true
        end

        it "returns false from health_check when not healthy" do
          subject.send(:break!)
          expect(subject.health_check).to be false
        end

      end

    end

  end

end
