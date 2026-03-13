# frozen_string_literal: true

RSpec.describe Types::ContributorKindType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :contributor_kind
end
