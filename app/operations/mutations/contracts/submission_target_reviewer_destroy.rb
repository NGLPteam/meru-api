# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionTargetReviewerDestroy
    # @see Mutations::Operations::SubmissionTargetReviewerDestroy
    class SubmissionTargetReviewerDestroy < MutationOperations::Contract
      json do
        required(:submission_target_reviewer).value(:submission_target_reviewer)
      end
    end
  end
end
