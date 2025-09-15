# frozen_string_literal: true

RSpec.describe Permalink, type: :model do
  context "when setting the kind" do
    let_it_be(:community, refind: true) { FactoryBot.create(:community) }
    let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }
    let_it_be(:item, refind: true) { FactoryBot.create(:item, collection:) }
    let_it_be(:user, refind: true) { FactoryBot.create(:user) }

    it "accepts an item" do
      permalink = FactoryBot.create(:permalink, permalinkable: item, uri: "item-link")
      expect(permalink.kind).to eq("item")
      expect(permalink).to be_to_item
    end

    it "accepts a collection" do
      permalink = FactoryBot.create(:permalink, permalinkable: collection, uri: "collection-link")
      expect(permalink.kind).to eq("collection")
      expect(permalink).to be_to_collection
    end

    it "accepts a community" do
      permalink = FactoryBot.create(:permalink, permalinkable: community, uri: "community-link")
      expect(permalink.kind).to eq("community")
      expect(permalink).to be_to_community
    end

    it "does not accept a non-Permalinkable model" do
      expect do
        FactoryBot.create(:permalink, permalinkable: user, uri: "user-link")
      end.to raise_error(ActiveRecord::InverseOfAssociationNotFoundError)
    end
  end

  context "when re-assigning a canonical permalink" do
    let_it_be(:permalinkable, refind: true) { FactoryBot.create(:community) }
    let_it_be(:other_permalinkable, refind: true) { FactoryBot.create(:community) }

    let_it_be(:old_canonical, refind: true) do
      FactoryBot.create(:permalink, :canon, permalinkable:, uri: "old-canonical")
    end

    context "with a non-canonical permalink" do
      let_it_be(:new_canonical) do
        FactoryBot.create(:permalink, permalinkable:, uri: "new-canonical")
      end

      it "allows the new permalink to be assigned as canonical" do
        expect do
          new_canonical.update!(canonical: true)
        end.to keep_the_same { permalinkable.permalinks.count }
          .and change { old_canonical.reload.canonical }.from(true).to(false)
          .and change { new_canonical.reload.canonical }.from(false).to(true)
          .and change(permalinkable, :reload_canonical_permalink).from(old_canonical).to(new_canonical)
      end
    end

    context "with a canonical permalink assigned to another linkable" do
      let_it_be(:new_canonical) do
        FactoryBot.create(:permalink, :canon, permalinkable: other_permalinkable, uri: "new-canonical")
      end

      it "allows the new canonical permalink to be assigned" do
        expect do
          new_canonical.update!(canonical: true, permalinkable:)
        end.to change { other_permalinkable.permalinks.count }.from(1).to(0)
          .and change { permalinkable.permalinks.count }.from(1).to(2)
          .and change { old_canonical.reload.canonical }.from(true).to(false)
          .and change(other_permalinkable, :reload_canonical_permalink).from(new_canonical).to(nil)
          .and change(permalinkable, :reload_canonical_permalink).from(old_canonical).to(new_canonical)
      end
    end
  end
end
