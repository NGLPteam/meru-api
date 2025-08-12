# frozen_string_literal: true

module Attributions
  module Collections
    # @api private
    # @see Attribution
    # @see Collection
    # @see CollectionAttribution
    # @see CollectionContribution
    # @see Contribution
    class Manage
      include Dry::Monads[:result, :do]

      include MeruAPI::Deps[
        upsert: "attributions.collections.upsert",
        prune: "attributions.collections.prune",
      ]

      # @param [Collection, nil] collection
      # @return [Dry::Monads::Success(Hash)]
      def call(collection: nil)
        upserted = yield upsert.(collection:)

        pruned = yield prune.(collection:)

        status = { upserted:, pruned:, }

        Success status
      end
    end
  end
end
