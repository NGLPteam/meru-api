# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::DepositorRequestCreate
    class DepositorRequestCreate
      include MutationOperations::Base

      use_contract! :depositor_request_create

      authorizes! :submission_target, with: :request_deposit_access?

      authorizes! :depositor_request, with: :create?

      # @param [DepositorRequest] depositor_request
      # @param [{ Symbol => Object }] attrs
      # @return [void]
      def call(depositor_request:, **attrs)
        assign_attributes!(depositor_request, **attrs)

        persist_model! depositor_request, attach_to: :depositor_request
      end

      before_prepare def initialize_depositor_request!
        args => { submission_target: }

        attrs = { submission_target: }

        attrs[:user] = current_user if current_user.present? && current_user.authenticated?

        args[:depositor_request] = DepositorRequest.new(**attrs)
      end
    end
  end
end
