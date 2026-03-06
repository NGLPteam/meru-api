# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionCommentUpdate
  class SubmissionCommentUpdate < Mutations::MutateSubmissionComment
    description <<~TEXT
    Update a single `SubmissionComment` record.
    TEXT

    argument :submission_comment_id, ID, loads: Types::SubmissionCommentType, required: true do
      description <<~TEXT
      The submission comment to update.
      TEXT
    end

    performs_operation! "mutations.operations.submission_comment_update"
  end
end
