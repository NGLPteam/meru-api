# frozen_string_literal: true

RSpec.describe Types::DatePrecisionType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :date_precision, symbolic: true
end
