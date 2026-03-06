# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionLeaveReview
    # @see Mutations::Operations::SubmissionLeaveReview
    class SubmissionLeaveReview < MutationOperations::Contract
      json do
        required(:submission).value(:submission)
        required(:to_state).value(:submission_review_state)
        optional(:comment).maybe(:string)
      end
    end
  end
end
