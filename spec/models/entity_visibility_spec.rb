# frozen_string_literal: true

RSpec.describe EntityVisibility, type: :model do
  let_it_be(:community, refind: true) { FactoryBot.create(:community) }

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

  let_it_be(:item, refind: true) { FactoryBot.create(:item, collection:) }

  specify "creating an entity creates its visibility" do
    expect do
      FactoryBot.create(:collection, community:)
    end.to change(described_class, :count).by(1)
  end

  context "when accessing visibility from an Entity" do
    let!(:entity) { item.entity }

    it "is synchronized" do
      expect do
        item.visibility = :hidden

        item.save!
      end.to change { entity.reload.visibility_hidden? }.from(false).to(true)
        .and change(EntityVisibilityTransition, :count).by(1)
        .and change(described_class.currently_visible, :count).by(-1)
        .and change(described_class.currently_hidden, :count).by(1)
        .and change(Item.currently_visible, :count).by(-1)
        .and change(Item.currently_hidden, :count).by(1)
    end
  end

  describe ".mismatched" do
    let_it_be(:community, refind: true) { FactoryBot.create(:community) }
    let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

    let_it_be(:entity_visibility, refind: true) { collection.entity_visibility }

    it "detects visibilities in the wrong state" do
      expect do
        entity_visibility.update_column :state, "hidden"
      end.to change { described_class.mismatched.count }.by(1)
    end

    it "detects limited visibilities in need of update" do
      expect do
        entity_visibility.update_columns(
          visibility: "limited",
          visible_after_at: 5.days.from_now,
          visible_until_at: 10.days.from_now
        )
      end.to change { described_class.mismatched.count }.by(1)
    end
  end
end
