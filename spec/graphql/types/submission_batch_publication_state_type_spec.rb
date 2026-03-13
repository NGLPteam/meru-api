# frozen_string_literal: true

RSpec.describe Types::SubmissionBatchPublicationStateType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :submission_batch_publication_state
end
