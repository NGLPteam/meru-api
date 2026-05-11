# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::ContributorClaim
    # @see Mutations::Operations::ContributorClaim
    class ContributorClaim < MutationOperations::Contract
      json do
        required(:contributor).value(:contributor)
      end
    end
  end
end
