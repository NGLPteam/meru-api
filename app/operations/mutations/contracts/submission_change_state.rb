# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionChangeState
    # @see Mutations::Operations::SubmissionChangeState
    class SubmissionChangeState < MutationOperations::Contract
      json do
        required(:submission).value(:submission)
        required(:to_state).value(:submission_state)
      end

      rule(:to_state) do
        submission = values[:submission]

        key.failure(:must_be_new_state) if value == submission.current_state
        base.failure(:unavailable_transition, from: submission.current_state, value: value) unless submission.can_transition_to?(value)
      end
    end
  end
end
