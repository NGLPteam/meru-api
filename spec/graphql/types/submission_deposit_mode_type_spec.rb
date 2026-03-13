# frozen_string_literal: true

RSpec.describe Types::SubmissionDepositModeType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :submission_deposit_mode
end
