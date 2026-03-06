# frozen_string_literal: true

module SubmissionReviews
  # @see SubmissionReview
  # @see SubmissionReviewTransition
  class StateMachine
    include Statesman::Machine
    include Support::StatesmanHelpers::Machine

    state :pending, initial: true
    state :approved
    state :rejected

    flexible_transitions!
  end
end
