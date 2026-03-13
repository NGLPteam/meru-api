# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::DepositorAgreementResetAll
  class DepositorAgreementResetAll < Mutations::BaseMutation
    description <<~TEXT
    Force all depositors to re-accept the depositor agreement for a given submission target.
    TEXT

    field :submission_target, Types::SubmissionTargetType, null: true do
      description "The submission target for which depositor agreements were reset."
    end

    argument :submission_target_id, ID, required: true, loads: Types::SubmissionTargetType do
      description "The ID of the submission target for which to reset depositor agreements."
    end

    performs_operation! "mutations.operations.depositor_agreement_reset_all"
  end
end
