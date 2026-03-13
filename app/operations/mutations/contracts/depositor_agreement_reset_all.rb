# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::DepositorAgreementResetAll
    # @see Mutations::Operations::DepositorAgreementResetAll
    class DepositorAgreementResetAll < MutationOperations::Contract
      json do
        required(:submission_target).value(:submission_target)
      end
    end
  end
end
