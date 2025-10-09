# frozen_string_literal: true

RSpec.describe CacheWarmers::RunWarmable, type: :operation do
  let_it_be(:community, refind: true) { FactoryBot.create(:community) }
  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }
  let_it_be(:item, refind: true) { FactoryBot.create(:item, collection:) }

  shared_examples_for "a cache warmable entity" do
    let(:entity) { raise "must be defined" }
    let(:enabled_by_default) { true }
    let(:disabled_result) { 0 }
    let(:entity_path) { FrontendConfig.entity_url_for(entity) }

    context "when the entity is turned on" do
      before do
        entity.cache_warming_on!
      end

      context "when the frontend is responding appropriately" do
        before do
          stub_request(:get, entity_path).to_return(status: 200, body: "", headers: {})
        end

        it "warms the cache" do
          expect do
            expect_calling_with(entity).to succeed.with(1)
          end.to change(CacheWarming.where(status: 200), :count).by(1)
        end
      end

      context "when the frontend times out" do
        before do
          stub_request(:get, entity_path).to_timeout
        end

        it "records the failure" do
          expect do
            expect_calling_with(entity).to succeed.with(1)
          end.to change(CacheWarming.where(status: -1), :count).by(1)
        end
      end

      context "when the frontend is not found" do
        before do
          stub_request(:get, entity_path).to_return(status: 404, body: "", headers: {})
        end

        it "records the failure" do
          expect do
            expect_calling_with(entity).to succeed.with(1)
          end.to change(CacheWarming.where(status: 404), :count).by(1)
        end
      end

      context "when the frontend is down" do
        before do
          stub_request(:get, entity_path).to_raise(Faraday::ConnectionFailed.new("Connection failed"))
        end

        it "records the failure" do
          expect do
            expect_calling_with(entity).to succeed.with(1)
          end.to change(CacheWarming.where(status: -1), :count).by(1)
        end
      end
    end

    context "when the entity is manually disabled" do
      before do
        entity.cache_warming_off!
      end

      it "skips the warming" do
        expect do
          expect_calling_with(entity).to succeed.with(disabled_result)
        end.to keep_the_same(CacheWarming, :count)
      end
    end
  end

  context "with a Community" do
    it_behaves_like "a cache warmable entity" do
      let(:entity) { community }
      let(:enabled_by_default) { true }
    end
  end

  context "with a Collection" do
    it_behaves_like "a cache warmable entity" do
      let(:entity) { collection }
      let(:enabled_by_default) { true }
    end
  end

  context "with an Item" do
    it_behaves_like "a cache warmable entity" do
      let(:entity) { item }
      let(:enabled_by_default) { false }
    end
  end
end
