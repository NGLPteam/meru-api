# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionTargetReviewerCreate
    # @see Mutations::Operations::SubmissionTargetReviewerCreate
    class SubmissionTargetReviewerCreate < MutationOperations::Contract
      json do
        required(:submission_target).filled(:submission_target)
        required(:user).filled(:user)
      end
    end
  end
end
