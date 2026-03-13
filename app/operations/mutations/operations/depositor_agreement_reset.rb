# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::DepositorAgreementReset
    class DepositorAgreementReset
      include MutationOperations::Base

      use_contract! :depositor_agreement_reset

      authorizes! :depositor_agreement, with: :reset?

      # @param [DepositorAgreement] depositor_agreement
      # @return [void]
      def call(depositor_agreement:, **)
        with_attached_result! :depositor_agreement, depositor_agreement.reset
      end

      before_prepare def fetch_depositor_agreement!
        args => { submission_target:, user: }

        args[:depositor_agreement] = submission_target.agreement_for(user)
      end
    end
  end
end
