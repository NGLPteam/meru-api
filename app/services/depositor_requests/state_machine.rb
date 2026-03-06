# frozen_string_literal: true

module DepositorRequests
  # @see DepositorRequest
  class StateMachine
    include Statesman::Machine
    include ::Support::StatesmanHelpers::Machine

    state :pending, initial: true
    state :approved
    state :rejected

    flexible_transitions!

    after_transition do |dr, transition|
      dr.update_column(:state, transition.to_state)
    end

    after_transition to: :approved do |dr, _transition|
      dr.add_depositor!
    end

    after_transition from: :approved do |dr, _transition|
      dr.remove_depositor!
    end
  end
end
