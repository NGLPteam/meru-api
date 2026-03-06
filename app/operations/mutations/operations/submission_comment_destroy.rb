# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionCommentDestroy
    class SubmissionCommentDestroy
      include MutationOperations::Base

      use_contract! :submission_comment_destroy

      authorizes! :submission_comment, with: :destroy?

      # @param [SubmissionComment] submission_comment
      # @return [void]
      def call(submission_comment:)
        destroy_model! submission_comment, auth: true
      end
    end
  end
end
