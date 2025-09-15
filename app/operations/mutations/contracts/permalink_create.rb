# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::PermalinkCreate
    # @see Mutations::Operations::PermalinkCreate
    class PermalinkCreate < MutationOperations::Contract
      json do
        required(:permalinkable).value(:permalinkable)
        required(:uri).filled(:string) { str? & min_size?(3) & max_size?(250) }
        required(:canonical).value(:bool)
      end

      rule(:uri) do
        key.failure(:must_be_unique) if Permalink.exists?(uri: value)
        key.failure(:must_be_valid_permalink_uri) unless Permalink::URI_FORMAT.match?(value)
      end
    end
  end
end
