# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionLeaveReview
  class SubmissionLeaveReview < Mutations::BaseMutation
    description <<~TEXT
    Leave a review on a submission.

    This effectively acts as an upsert and can be run by itself,
    or as a response to `submissionRequestReview`.
    TEXT

    field :submission, Types::SubmissionType, null: true do
      description <<~TEXT
      The associated submission.
      TEXT
    end

    field :submission_review, Types::SubmissionReviewType, null: true do
      description <<~TEXT
      The associated review.
      TEXT
    end

    argument :submission_id, ID, loads: ::Types::SubmissionType, required: true do
      description <<~TEXT
      The submission to review.
      TEXT
    end

    argument :to_state, Types::SubmissionReviewStateType, required: true do
      description <<~TEXT
      The submission state to be placed in.
      TEXT
    end

    argument :comment, String, required: false do
      description <<~TEXT
      An additional comment to store with the review proper.
      TEXT
    end

    performs_operation! "mutations.operations.submission_leave_review"
  end
end
