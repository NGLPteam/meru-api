# frozen_string_literal: true

RSpec.describe Types::RolePrimacyType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :role_primacy
end
