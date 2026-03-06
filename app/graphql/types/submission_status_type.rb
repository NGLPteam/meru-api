# frozen_string_literal: true

module Types
  # @see Submissions::Status
  # @see SubmissionStatusPolicy
  class SubmissionStatusType < Types::BaseObject
    description <<~TEXT
    Information about submission status and a particular state.

    This object does double duty for both current status and available transitions.
    TEXT

    field :from_state, Types::SubmissionStateType, null: false do
      description <<~TEXT
      The current state of the submission.
      TEXT
    end

    field :to_state, Types::SubmissionStateType, null: false do
      description <<~TEXT
      The state to which the submission can be transitioned.
      TEXT
    end

    field :locked_state, Boolean, null: false do
      description <<~TEXT
      Whether the submission will be in a locked state (i.e. not mutable by the depositor).
      TEXT
    end

    field :mutable_state, Boolean, null: false do
      description <<~TEXT
      Whether the submission will be in a mutable state (i.e. mutable by the depositor).
      TEXT
    end

    expose_authorization_rule :transition?, <<~TEXT
    Whether the current user is allowed to transition the submission to this state.
    TEXT
  end
end
