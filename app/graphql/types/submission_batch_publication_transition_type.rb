# frozen_string_literal: true

module Types
  # @see SubmissionBatchPublicationTransition
  # @see ::Types::SubmissionBatchPublicationTransitionConnectionType
  # @see ::Types::SubmissionBatchPublicationTransitionEdgeType
  class SubmissionBatchPublicationTransitionType < Types::AbstractModel
    description <<~TEXT
    A transition for a `SubmissionBatchPublication`.
    TEXT

    use_direct_connection_and_edge!

    implements ::Types::CommonTransitionType

    field :from_state, Types::SubmissionBatchPublicationStateType, null: true do
      description <<~TEXT
      The state that the submission batch publication is transitioning from. This will be null if the submission target is being created.
      TEXT
    end

    field :to_state, Types::SubmissionBatchPublicationStateType, null: false do
      description <<~TEXT
      The state that the submission batch publication is transitioning to.
      TEXT
    end
  end
end
