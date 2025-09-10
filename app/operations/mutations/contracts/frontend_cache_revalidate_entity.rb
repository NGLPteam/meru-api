# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::FrontendCacheRevalidateEntity
    # @see Mutations::Operations::FrontendCacheRevalidateEntity
    class FrontendCacheRevalidateEntity < MutationOperations::Contract
      json do
        required(:entity).value(:any_entity)
      end
    end
  end
end
