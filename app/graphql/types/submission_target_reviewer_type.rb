# frozen_string_literal: true

module Types
  # @see SubmissionTargetReviewer
  class SubmissionTargetReviewerType < Types::AbstractModel
    description <<~TEXT
    A reviewer assigned to a `SubmissionTarget`.
    TEXT

    use_direct_connection_and_edge!

    field :submission_target, "::Types::SubmissionTargetType", null: false do
      description "The submission target this reviewer is assigned to."
    end

    field :user, "::Types::UserType", null: false do
      description "The user assigned as a reviewer."
    end

    load_association! :submission_target

    load_association! :user
  end
end
