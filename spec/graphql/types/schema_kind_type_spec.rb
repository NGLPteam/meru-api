# frozen_string_literal: true

RSpec.describe Types::SchemaKindType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :schema_kind
end
