require "spec_helper"
require "snowden"

module Snowden
  describe EncryptedSearchIndex do
    subject(:index) {
      EncryptedSearchIndex.new(
        :crypto             => crypto,
        :backend            => backend,
        :wildcard_generator => wildcard_generator,
      )
    }

    let(:crypto)                 { double("crypto") }
    let(:key)                    { double("key")   }
    let(:value)                  { double("value") }
    let(:wildcard_key)           { double("wildcard key") }
    let(:encrypted_wildcard_key) { double("encrypted wildcard key") }
    let(:encrypted_value)        { double("encrypted value") }
    let(:backend)                { double("backend", :save => nil) }
    let(:wildcard_generator)     { double("wildcard_generator") }


    describe "#save" do
      it "stores the wildcard and the encrypted value" do
        allow(wildcard_generator).to receive(:wildcards).with(key).and_return([wildcard_key].to_enum)
        allow(crypto).to receive(:encrypt).with(wildcard_key).and_return(encrypted_wildcard_key)
        allow(crypto).to receive(:padded_encrypt).with(value).and_return(encrypted_value)

        index.store(key, value)

        expect(backend).to have_received(:save).with(encrypted_wildcard_key, encrypted_value)
      end
    end

    describe "#search" do
      it "retreives the value matching the passed encrypted value" do
        allow(backend).to receive(:find).with(encrypted_wildcard_key).and_return(encrypted_value)
        expect(index.search(encrypted_wildcard_key)).to be == encrypted_value
      end
    end
  end
end
