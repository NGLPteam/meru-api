# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionRequestReview
    # @see Mutations::Operations::SubmissionRequestReview
    class SubmissionRequestReview < MutationOperations::Contract
      json do
        required(:submission).value(:submission)
        required(:user).value(:user)
      end
    end
  end
end
