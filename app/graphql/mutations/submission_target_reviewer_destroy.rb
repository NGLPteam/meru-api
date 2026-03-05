# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionTargetReviewerDestroy
  class SubmissionTargetReviewerDestroy < Mutations::BaseMutation
    description <<~TEXT
    Destroy a single `SubmissionTargetReviewer` record.
    TEXT

    argument :submission_target_reviewer_id, ID, loads: Types::SubmissionTargetReviewerType, required: true do
      description <<~TEXT
      The submission target reviewer to destroy.
      TEXT
    end

    performs_operation! "mutations.operations.submission_target_reviewer_destroy", destroy: true
  end
end
