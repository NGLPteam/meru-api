# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::DepositorAgreementResetAll
    class DepositorAgreementResetAll
      include MutationOperations::Base

      use_contract! :depositor_agreement_reset_all

      authorizes! :submission_target, with: :reset_all_agreements?

      # @param [{ Symbol => Object }] args
      # @return [void]
      def call(submission_target:, **)
        submission_target.depositor_agreements.reset_all!

        attach! :submission_target, submission_target
      end
    end
  end
end
