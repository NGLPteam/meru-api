# frozen_string_literal: true

module Types
  # @see SubmissionReview
  # @see ::Types::SubmissionReviewConnectionType
  # @see ::Types::SubmissionReviewEdgeType
  class SubmissionReviewType < Types::AbstractModel
    description <<~TEXT
    A review of a `Submission` by a specific reviewer.
    TEXT

    use_direct_connection_and_edge!

    field :state, Types::SubmissionReviewStateType, null: false do
      description <<~TEXT
      The current state of this submission review.
      TEXT
    end

    field :submission, "::Types::SubmissionType", null: false do
      description <<~TEXT
      The submission that this is a review of.
      TEXT
    end

    field :user, "::Types::UserType", null: true do
      description <<~TEXT
      The user that created this submission review, if any.
      TEXT
    end

    field :transitions, resolver: ::Resolvers::SubmissionReviewTransitionResolver, null: false do
      description <<~TEXT
      The state transitions that this submission review has undergone.
      TEXT
    end
  end
end
