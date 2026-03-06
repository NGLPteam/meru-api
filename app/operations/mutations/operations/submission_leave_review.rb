# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionLeaveReview
    class SubmissionLeaveReview
      include MutationOperations::Base

      use_contract! :submission_leave_review

      authorizes! :submission, with: :review?

      # @param [Submission] submission
      # @param [String] to_state
      # @param [String, nil] comment
      # @return [void]
      def call(submission:, to_state:, comment:, **)
        submission_review = submission.submission_reviews.find_or_initialize_by(user: current_user)

        submission_review.update!(comment:)

        # Review states are flexible, there are no invalid transitions.
        submission_review.transition_to(to_state) if submission_review.can_transition_to?(to_state)

        attach! :submission_review, submission_review
        attach! :submission, submission.reload
      end
    end
  end
end
