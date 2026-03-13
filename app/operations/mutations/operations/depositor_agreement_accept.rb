# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::DepositorAgreementAccept
    class DepositorAgreementAccept
      include MutationOperations::Base

      use_contract! :depositor_agreement_accept

      authorizes! :depositor_agreement, with: :accept?

      # @param [DepositorAgreement] depositor_agreement
      # @return [void]
      def call(depositor_agreement:, **)
        with_attached_result! :depositor_agreement, depositor_agreement.accept
      end

      before_prepare def fetch_depositor_agreement!
        args => { submission_target: }

        args[:depositor_agreement] = submission_target.agreement_for(current_user.authenticated)
      end
    end
  end
end
