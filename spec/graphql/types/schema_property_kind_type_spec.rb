# frozen_string_literal: true

RSpec.describe Types::SchemaPropertyKindType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :schema_property_kind
end
