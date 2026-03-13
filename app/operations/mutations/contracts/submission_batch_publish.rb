# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionBatchPublish
    # @see Mutations::Operations::SubmissionBatchPublish
    class SubmissionBatchPublish < MutationOperations::Contract
      json do
        required(:submission_target).value(:submission_target)
        required(:submissions).array(:submission)
      end

      rule(:submissions).each do
        key.failure(:mismatched_batch_submission_target) if value.submission_target != values[:submission_target]
        key.failure(:must_be_publishable) unless value.can_transition_to?(:published)
      end
    end
  end
end
