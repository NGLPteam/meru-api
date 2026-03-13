# frozen_string_literal: true

RSpec.describe Types::SchemaPropertyFunctionType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :schema_property_function
end
