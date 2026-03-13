# frozen_string_literal: true

RSpec.describe Types::SubmissionReviewStateType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :submission_review_state
end
