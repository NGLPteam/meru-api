# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionCommentUpdate
    class SubmissionCommentUpdate
      include MutationOperations::Base

      use_contract! :submission_comment_update
      use_contract! :mutate_submission_comment

      authorizes! :submission_comment, with: :update?

      # @param [SubmissionComment] submission_comment
      # @param [{ Symbol => Object }] attrs
      # @return [void]
      def call(submission_comment:, **attrs)
        assign_attributes!(submission_comment, **attrs)

        persist_model! submission_comment, attach_to: :submission_comment
      end
    end
  end
end
