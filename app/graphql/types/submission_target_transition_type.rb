# frozen_string_literal: true

module Types
  # @see SubmissionTargetTransition
  # @see ::Types::SubmissionTargetTransitionConnectionType
  # @see ::Types::SubmissionTargetTransitionEdgeType
  class SubmissionTargetTransitionType < Types::AbstractModel
    description <<~TEXT
    A transition for a `SubmissionTarget`.
    TEXT

    use_direct_connection_and_edge!

    implements ::Types::CommonTransitionType

    field :from_state, Types::SubmissionTargetStateType, null: true do
      description <<~TEXT
      The state that the submission target is transitioning from. This will be null if the submission target is being created.
      TEXT
    end

    field :to_state, Types::SubmissionTargetStateType, null: false do
      description <<~TEXT
      The state that the submission target is transitioning to.
      TEXT
    end
  end
end
