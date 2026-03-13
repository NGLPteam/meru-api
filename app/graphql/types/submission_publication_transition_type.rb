# frozen_string_literal: true

module Types
  # @see SubmissionPublicationTransition
  # @see ::Types::SubmissionPublicationTransitionConnectionType
  # @see ::Types::SubmissionPublicationTransitionEdgeType
  class SubmissionPublicationTransitionType < Types::AbstractModel
    description <<~TEXT
    A transition for a `SubmissionPublication`.
    TEXT

    use_direct_connection_and_edge!

    implements ::Types::CommonTransitionType

    field :from_state, Types::SubmissionPublicationStateType, null: true do
      description <<~TEXT
      The state that the submission publication is transitioning from. This will be null if the submission target is being created.
      TEXT
    end

    field :to_state, Types::SubmissionPublicationStateType, null: false do
      description <<~TEXT
      The state that the submission publication is transitioning to.
      TEXT
    end
  end
end
