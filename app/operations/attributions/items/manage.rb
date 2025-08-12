# frozen_string_literal: true

module Attributions
  module Items
    # @api private
    # @see Attribution
    # @see Item
    # @see ItemAttribution
    # @see ItemContribution
    # @see Contribution
    class Manage
      include Dry::Monads[:result, :do]

      include MeruAPI::Deps[
        upsert: "attributions.items.upsert",
        prune: "attributions.items.prune",
      ]

      # @param [Item, nil] item
      # @return [Dry::Monads::Success(Hash)]
      def call(item: nil)
        upserted = yield upsert.(item:)

        pruned = yield prune.(item:)

        status = { upserted:, pruned:, }

        Success status
      end
    end
  end
end
