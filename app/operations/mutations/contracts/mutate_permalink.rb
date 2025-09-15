# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::MutatePermalink
    class MutatePermalink < MutationOperations::Contract
      json do
        required(:permalinkable).value(:permalinkable)
        required(:uri).filled(:string) { str? & min_size?(3) & max_size?(250) }
        required(:canonical).value(:bool)
      end

      rule(:uri) do
        key.failure(:must_be_valid_permalink_uri) unless Permalink::URI_FORMAT.match?(value)
      end
    end
  end
end
