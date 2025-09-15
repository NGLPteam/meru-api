# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::PermalinkDestroy
    # @see Mutations::Operations::PermalinkDestroy
    class PermalinkDestroy < MutationOperations::Contract
      json do
        required(:permalink).value(:permalink)
      end
    end
  end
end
