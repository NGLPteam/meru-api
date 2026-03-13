# frozen_string_literal: true

module SubmissionReviews
  # @see SubmissionReview
  # @see SubmissionReviewTransition
  class StateMachine
    include Statesman::Machine
    include Support::StatesmanHelpers::Machine

    state :pending, initial: true
    state :revision_requested
    state :approved
    state :rejected

    flexible_transitions!

    after_transition do |submission_review, transition|
      submission_review.update_column(:state, transition.to_state)
    end
  end
end
