# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionTargetOpen
    # @see Mutations::Operations::SubmissionTargetOpen
    class SubmissionTargetOpen < MutationOperations::Contract
      json do
        required(:submission_target).value(:submission_target)
      end

      rule(:submission_target) do
        base.failure(:unavailable_transition, value: "open") unless value.can_transition_to?(:open)
      end
    end
  end
end
