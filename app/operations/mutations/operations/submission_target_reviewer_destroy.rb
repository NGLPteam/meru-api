# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionTargetReviewerDestroy
    class SubmissionTargetReviewerDestroy
      include MutationOperations::Base

      use_contract! :submission_target_reviewer_destroy

      # @param [SubmissionTargetReviewer] submission_target_reviewer
      # @return [void]
      def call(submission_target_reviewer:)
        destroy_model! submission_target_reviewer, auth: true
      end
    end
  end
end
