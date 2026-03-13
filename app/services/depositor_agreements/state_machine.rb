# frozen_string_literal: true

module DepositorAgreements
  # @see SubmissionReview
  # @see SubmissionReviewTransition
  class StateMachine
    include Statesman::Machine
    include Support::StatesmanHelpers::Machine

    state :pending, initial: true
    state :accepted

    transition from: :pending, to: :accepted

    transition from: :accepted, to: :pending

    after_transition do |depositor_agreement, transition|
      depositor_agreement.update_column(:state, transition.to_state)
    end

    after_transition to: :accepted do |depositor_agreement|
      depositor_agreement.touch(:last_accepted_at)
    end
  end
end
