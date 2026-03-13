# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::DepositorAgreementReset
    # @see Mutations::Operations::DepositorAgreementReset
    class DepositorAgreementReset < MutationOperations::Contract
      json do
        required(:submission_target).value(:submission_target)
        required(:user).value(:user)
      end
    end
  end
end
