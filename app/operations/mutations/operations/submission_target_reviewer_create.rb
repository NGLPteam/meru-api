# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionTargetReviewerCreate
    class SubmissionTargetReviewerCreate
      include MutationOperations::Base

      use_contract! :submission_target_reviewer_create

      authorizes! :submission_target_reviewer, with: :create?

      # @param [SubmissionTargetReviewer] submission_target_reviewer
      # @return [void]
      def call(submission_target_reviewer:, **)
        persist_model! submission_target_reviewer, attach_to: :submission_target_reviewer
      end

      before_prepare def find_or_initialize_reviewer!
        args => { submission_target:, user: }

        args[:submission_target_reviewer] = SubmissionTargetReviewer.find_or_initialize_by(submission_target:, user:)
      end
    end
  end
end
