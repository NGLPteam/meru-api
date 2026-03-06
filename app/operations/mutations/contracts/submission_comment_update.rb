# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionCommentUpdate
    # @see Mutations::Operations::SubmissionCommentUpdate
    class SubmissionCommentUpdate < MutationOperations::Contract
      json do
        required(:submission_comment).value(:submission_comment)
      end
    end
  end
end
