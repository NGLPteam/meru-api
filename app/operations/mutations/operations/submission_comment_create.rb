# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionCommentCreate
    class SubmissionCommentCreate
      include MutationOperations::Base

      use_contract! :submission_comment_create
      use_contract! :mutate_submission_comment

      authorizes! :submission_comment, with: :create?

      # @param [SubmissionComment] submission_comment
      # @param [{ Symbol => Object }] attrs
      # @return [void]
      def call(submission_comment:, **attrs)
        assign_attributes!(submission_comment, **attrs)

        persist_model! submission_comment, attach_to: :submission_comment
      end

      before_prepare def initialize_submission_comment!
        args => { submission: }

        attrs = { submission: }

        attrs[:user] = current_user if current_user.present? && current_user.authenticated?

        args[:submission_comment] = SubmissionComment.new(**attrs)
      end
    end
  end
end
