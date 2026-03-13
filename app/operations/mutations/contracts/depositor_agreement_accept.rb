# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::DepositorAgreementAccept
    # @see Mutations::Operations::DepositorAgreementAccept
    class DepositorAgreementAccept < MutationOperations::Contract
      json do
        required(:submission_target).value(:submission_target)
      end
    end
  end
end
