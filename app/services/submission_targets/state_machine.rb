# frozen_string_literal: true

module SubmissionTargets
  # @see SubmissionTarget
  class StateMachine
    include Statesman::Machine

    state :closed, initial: true
    state :open

    transition from: :closed, to: :open
    transition from: :open, to: :closed

    guard_transition to: :open do |submission_target|
      submission_target.valid?(:opening)
    end

    after_transition do |submission_target, transition|
      submission_target.update_column(:state, transition.to_state)
    end
  end
end
