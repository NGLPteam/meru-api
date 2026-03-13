# frozen_string_literal: true

RSpec.describe Types::SiblingKindType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :sibling_kind
end
