# frozen_string_literal: true

RSpec.describe Entities::CalculateAuthorizing, type: :operation do
  let_it_be(:item, refind: true) { FactoryBot.create :item }

  it "works from an entity alias" do
    expect(item.calculate_authorizing).to succeed
  end

  it "works with an auth path" do
    expect_calling_with(auth_path: item.entity_auth_path).to succeed
  end

  it "works with no args" do
    expect_calling.to succeed
  end
end
