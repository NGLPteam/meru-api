# frozen_string_literal: true

RSpec.describe Types::SubmissionTargetStateType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :submission_target_state
end
