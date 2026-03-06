# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::DepositorRequestChangeState
    # @see Mutations::Operations::DepositorRequestChangeState
    class DepositorRequestChangeState < MutationOperations::Contract
      json do
        required(:depositor_request).value(:depositor_request)
        required(:to_state).value(:depositor_request_state)
      end

      rule(:to_state) do
        depositor_request = values[:depositor_request]

        key.failure(:must_be_new_state) if value == depositor_request.current_state
        base.failure(:unavailable_transition, from: depositor_request.current_state, value: value) unless depositor_request.can_transition_to?(value)
      end
    end
  end
end
