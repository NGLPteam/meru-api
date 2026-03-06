# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionTargetClose
    # @see Mutations::Operations::SubmissionTargetClose
    class SubmissionTargetClose < MutationOperations::Contract
      json do
        required(:submission_target).value(:submission_target)
      end

      rule(:submission_target) do
        base.failure(:unavailable_transition, value: "closed") unless value.can_transition_to?(:closed)
      end
    end
  end
end
