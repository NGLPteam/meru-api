# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::DepositorRequestChangeState
    class DepositorRequestChangeState
      include MutationOperations::Base

      use_contract! :depositor_request_change_state

      authorizes! :depositor_request, with: :update?

      # @param [DepositorRequest] depositor_request
      # @param [String] to_state
      # @return [void]
      def call(depositor_request:, to_state:, **)
        depositor_request.transition_to! to_state

        attach! :depositor_request, depositor_request.reload
      end
    end
  end
end
