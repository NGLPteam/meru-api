# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::DepositorAgreementAccept
  class DepositorAgreementAccept < Mutations::BaseMutation
    description <<~TEXT
    Accept the depositor agreement for the given submission target.
    TEXT

    field :depositor_agreement, Types::DepositorAgreementType, null: true do
      description "The depositor agreement that was accepted."
    end

    argument :submission_target_id, ID, required: true, loads: Types::SubmissionTargetType do
      description "The ID of the submission target that the agreement belongs to."
    end

    performs_operation! "mutations.operations.depositor_agreement_accept"
  end
end
