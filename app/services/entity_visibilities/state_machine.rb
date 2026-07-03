# frozen_string_literal: true

module EntityVisibilities
  class StateMachine
    include Statesman::Machine

    state :visible, initial: true
    state :hidden

    transition from: :visible, to: :hidden
    transition from: :visible, to: :visible

    transition from: :hidden, to: :visible
    transition from: :hidden, to: :hidden

    after_transition do |record, transition|
      state = transition.to_state
      active = state == "visible"

      record.update_columns(state:, active:)

      record.asynchronously_invalidate_related_orderings!
    end
  end
end
