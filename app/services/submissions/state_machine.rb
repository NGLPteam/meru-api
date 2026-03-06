# frozen_string_literal: true

module Submissions
  # @see Submission
  class StateMachine
    include Statesman::Machine

    state :draft, initial: true
    state :submitted
    state :under_review
    state :revision_requested
    state :approved
    state :rejected
    state :published

    transition from: :draft, to: :submitted

    transition from: :submitted, to: :draft
    transition from: :submitted, to: :under_review

    transition from: :under_review, to: :revision_requested
    transition from: :under_review, to: :approved
    transition from: :under_review, to: :rejected

    transition from: :revision_requested, to: :submitted

    transition from: :approved, to: :under_review
    transition from: :approved, to: :revision_requested
    transition from: :approved, to: :published

    after_transition do |submission, transition|
      submission.update_column(:state, transition.to_state)
    end
  end
end
