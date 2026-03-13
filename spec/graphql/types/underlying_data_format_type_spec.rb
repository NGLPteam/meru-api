# frozen_string_literal: true

RSpec.describe Types::UnderlyingDataFormatType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :underlying_data_format
end
