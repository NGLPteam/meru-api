# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionChangeState
  class SubmissionChangeState < Mutations::BaseMutation
    description <<~TEXT
    A mutation to change the state of a `Submission`.
    TEXT

    field :submission, ::Types::SubmissionType, null: true do
      description <<~TEXT
      The modified submission, if successful.
      TEXT
    end

    argument :submission_id, ID, loads: Types::SubmissionType, required: true do
      description <<~TEXT
      The ID of the {Submission} to update.
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
