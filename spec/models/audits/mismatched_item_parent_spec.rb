# frozen_string_literal: true

RSpec.describe Audits::MismatchedItemParent, type: :model, disable_ordering_refresh: true do
  let!(:collection) { FactoryBot.create :collection }
  let!(:item) { FactoryBot.create :item, collection: }
  let!(:subitem) { FactoryBot.create :item, parent: item }
  let!(:invalid_collection) { FactoryBot.create :collection }

  it "detects invalid parentages" do
    expect do
      subitem.update_column :collection_id, invalid_collection.id
    end.to change(described_class, :count).by(1)

    first = described_class.first!

    expect(first).to have_attributes(
      item: subitem,
      invalid_collection:,
      valid_collection: collection,
    )
  end
end
