# frozen_string_literal: true

RSpec.describe Types::SubmissionPublicationStateType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :submission_publication_state
end
