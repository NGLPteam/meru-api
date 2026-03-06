# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionRequestReview
  class SubmissionRequestReview < Mutations::BaseMutation
    description <<~TEXT
    Request a review from a reviewer.

    This effectively acts as an upsert.

    The reviewer is expected to call `submissionLeaveReview`.
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

    argument :user_id, ID, loads: ::Types::UserType, required: true do
      description <<~TEXT
      The id of the user to request the review from.
      TEXT
    end

    argument :comment, String, required: false do
      description <<~TEXT
      An optional comment to store alongside the review.
      TEXT
    end

    performs_operation! "mutations.operations.submission_request_review"
  end
end
