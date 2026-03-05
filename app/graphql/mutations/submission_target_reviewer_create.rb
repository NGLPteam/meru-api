# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionTargetReviewerCreate
  class SubmissionTargetReviewerCreate < Mutations::BaseMutation
    description <<~TEXT
    Create a single `SubmissionTargetReviewer` record.
    TEXT

    field :submission_target_reviewer, Types::SubmissionTargetReviewerType, null: true do
      description <<~TEXT
      The newly-modified submission target reviewer, if successful.
      TEXT
    end

    argument :submission_target_id, ID, loads: Types::SubmissionTargetType, required: true do
      description <<~TEXT
      The ID of the `SubmissionTarget` to assign a reviewer to.
      TEXT
    end

    argument :user_id, ID, loads: Types::UserType, required: true do
      description <<~TEXT
      The ID of the `User` to assign the reviewer role to.
      TEXT
    end

    performs_operation! "mutations.operations.submission_target_reviewer_create"
  end
end
