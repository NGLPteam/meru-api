# frozen_string_literal: true

module Types
  # @see SubmissionReviewTransition
  # @see ::Types::SubmissionReviewTransitionConnectionType
  # @see ::Types::SubmissionReviewTransitionEdgeType
  class SubmissionReviewTransitionType < Types::AbstractModel
    description <<~TEXT
    A transition for a `SubmissionReview`.
    TEXT

    use_direct_connection_and_edge!

    implements ::Types::CommonTransitionType

    field :from_state, Types::SubmissionReviewStateType, null: true do
      description <<~TEXT
      The state that the submission target is transitioning from. This will be null if the submission target is being created.
      TEXT
    end

    field :to_state, Types::SubmissionReviewStateType, null: false do
      description <<~TEXT
      The state that the submission target is transitioning to.
      TEXT
    end
  end
end
