# frozen_string_literal: true

module DepositorAgreements
  # @see DepositorAgreements::Reset
  class Resetter < AbstractStateEnforcer
    target_state "pending"
  end
end
