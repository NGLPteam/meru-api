# frozen_string_literal: true

module DepositorAgreements
  # @see DepositorAgreements::Accept
  class Accepter < AbstractStateEnforcer
    target_state "accepted"
  end
end
