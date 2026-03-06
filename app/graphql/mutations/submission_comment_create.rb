# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionCommentCreate
  class SubmissionCommentCreate < Mutations::MutateSubmissionComment
    description <<~TEXT
    Create a single `SubmissionComment` record.
    TEXT

    argument :submission_id, ID, loads: Types::SubmissionType, required: true do
      description <<~TEXT
      The ID of the `Submission` to which the comment will be attached.
      TEXT
    end

    performs_operation! "mutations.operations.submission_comment_create"
  end
end
