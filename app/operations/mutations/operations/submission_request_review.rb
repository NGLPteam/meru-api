# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionRequestReview
    class SubmissionRequestReview
      include MutationOperations::Base

      use_contract! :submission_request_review

      authorizes! :submission, with: :request_review?

      # @param [Submission] submission
      # @param [User] user
      # @return [void]
      def call(submission:, user:, **)
        submission_review = submission.submission_reviews.find_or_initialize_by(user:)

        persist_model! submission_review, attach_to: :submission_review

        attach! :submission, submission.reload
      end
    end
  end
end
