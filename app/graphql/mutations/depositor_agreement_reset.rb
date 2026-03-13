# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::DepositorAgreementReset
  class DepositorAgreementReset < Mutations::BaseMutation
    description <<~TEXT
    Reset a specific depositor agreement, forcing the associated depositor to re-accept the agreement before making any more deposits to the associated submission target.
    TEXT

    field :depositor_agreement, Types::DepositorAgreementType, null: true do
      description "The depositor agreement that was reset."
    end

    argument :submission_target_id, ID, required: true, loads: Types::SubmissionTargetType do
      description "The ID of the submission target for which to reset a depositor agreement."
    end

    argument :user_id, ID, required: true, loads: Types::UserType do
      description "The ID of the user for which to reset a depositor agreement."
    end

    performs_operation! "mutations.operations.depositor_agreement_reset"
  end
end
