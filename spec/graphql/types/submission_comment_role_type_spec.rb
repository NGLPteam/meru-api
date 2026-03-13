# frozen_string_literal: true

RSpec.describe Types::SubmissionCommentRoleType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :submission_comment_role
end
