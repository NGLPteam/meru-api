# frozen_string_literal: true

RSpec.describe Types::PermalinkableKindType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :permalinkable_kind
end
