# frozen_string_literal: true

RSpec.describe Types::AccessManagementType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :access_management
end
