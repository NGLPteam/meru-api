# frozen_string_literal: true

RSpec.describe Types::EntityVisibilityType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :entity_visibility
end
