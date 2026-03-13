# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionPublish
    # @see Mutations::Operations::SubmissionPublish
    class SubmissionPublish < MutationOperations::Contract
      json do
        required(:submission).value(:submission)
      end

      rule(:submission) do
        key.failure(:must_be_publishable) unless value.can_transition_to?(:published)
      end
    end
  end
end
