# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionCommentDestroy
    # @see Mutations::Operations::SubmissionCommentDestroy
    class SubmissionCommentDestroy < MutationOperations::Contract
      json do
        required(:submission_comment).value(:submission_comment)
      end
    end
  end
end
