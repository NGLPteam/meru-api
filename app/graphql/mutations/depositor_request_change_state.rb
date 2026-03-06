# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::DepositorRequestChangeState
  class DepositorRequestChangeState < Mutations::BaseMutation
    description <<~TEXT
    Update the state for a `DepositorRequest` record.
    TEXT

    field :depositor_request, Types::DepositorRequestType, null: true do
      description <<~TEXT
      The newly-modified depositor request, if successful.
      TEXT
    end

    argument :depositor_request_id, ID, loads: Types::DepositorRequestType, required: true do
      description <<~TEXT
      The depositor request to update.
      TEXT
    end

    argument :to_state, Types::DepositorRequestStateType, required: true do
      description <<~TEXT
      The state to transition the depositor request to. Valid states are `approved` and `rejected`.
      TEXT
    end

    performs_operation! "mutations.operations.depositor_request_change_state"
  end
end
