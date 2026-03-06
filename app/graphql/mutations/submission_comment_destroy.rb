# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionCommentDestroy
  class SubmissionCommentDestroy < Mutations::BaseMutation
    description <<~TEXT
    Destroy a single `SubmissionComment` record.
    TEXT

    argument :submission_comment_id, ID, loads: Types::SubmissionCommentType, required: true do
      description <<~TEXT
      The submission comment to destroy.
      TEXT
    end

    performs_operation! "mutations.operations.submission_comment_destroy", destroy: true
  end
end
