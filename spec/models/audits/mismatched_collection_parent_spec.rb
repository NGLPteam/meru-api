# frozen_string_literal: true

RSpec.describe Audits::MismatchedCollectionParent, type: :model, disable_ordering_refresh: true do
  let!(:community) { FactoryBot.create :community }
  let!(:collection) { FactoryBot.create :collection, community: }
  let!(:subcollection) { FactoryBot.create :collection, parent: collection }
  let!(:invalid_community) { FactoryBot.create :community }

  it "detects invalid parentages" do
    expect do
      subcollection.update_column :community_id, invalid_community.id
    end.to change(described_class, :count).by(1)

    first = described_class.first!

    expect(first).to have_attributes(
      collection: subcollection,
      invalid_community:,
      valid_community: community,
    )
  end
end
