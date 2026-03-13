# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionBatchPublish
    class SubmissionBatchPublish
      include MutationOperations::Base

      use_contract! :submission_batch_publish

      authorizes! :submission_target, with: :publish?
      authorizes! :submissions, with: :publish?, each: true

      # @param [SubmissionTarget] submission_target
      # @param [<Submission>] submissions
      # @return [void]
      def call(submission_target:, submissions:, **)
        result = submission_target.batch_publish(*submissions, user: current_user)

        with_attached_result! :submission_batch_publication, result

        attach! :submission_target, submission_target.reload
      end
    end
  end
end
