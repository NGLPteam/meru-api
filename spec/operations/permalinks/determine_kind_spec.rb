# frozen_string_literal: true

RSpec.describe Permalinks::DetermineKind, type: :operation do
  let_it_be(:community) { FactoryBot.create(:community) }
  let_it_be(:collection) { FactoryBot.create(:collection, community:) }
  let_it_be(:item) { FactoryBot.create(:item, collection:) }
  let_it_be(:user) { FactoryBot.create(:user) }

  it "accepts a community" do
    expect_calling_with(community).to succeed.with("community")
  end

  it "accepts a collection" do
    expect_calling_with(collection).to succeed.with("collection")
  end

  it "accepts an item" do
    expect_calling_with(item).to succeed.with("item")
  end

  it "explodes on a non-Permalinkable model" do
    expect do
      operation.(user)
    end.to raise_error(TypeError, /Unknown permalinkable record: User/)
  end
end
