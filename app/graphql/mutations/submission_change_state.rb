# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionChangeState
  class SubmissionChangeState < Mutations::BaseMutation
    description <<~TEXT
    A mutation to change the state of a `Submission`.
    TEXT

    argument :submission_target_id, ID, loads: Types::SubmissionTargetType, required: true do
      description <<~TEXT
      The ID of the {SubmissionTarget} against which the submission is being made.
      TEXT
    end

    argument :to_state, Types::SubmissionStateType, required: true do
      description <<~TEXT
      The state to which the submission should be transitioned.
      TEXT
    end

    performs_operation! "mutations.operations.submission_change_state"
  end
end
