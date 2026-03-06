# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionCommentCreate
    # @see Mutations::Operations::SubmissionCommentCreate
    class SubmissionCommentCreate < MutationOperations::Contract
      json do
        required(:submission).value(:submission)
      end
    end
  end
end
