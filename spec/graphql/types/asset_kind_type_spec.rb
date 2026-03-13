# frozen_string_literal: true

RSpec.describe Types::AssetKindType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :asset_kind
end
