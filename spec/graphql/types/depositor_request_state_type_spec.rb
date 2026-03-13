# frozen_string_literal: true

RSpec.describe Types::DepositorRequestStateType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :depositor_request_state
end
