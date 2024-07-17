# frozen_string_literal: true

module Harvesting
  module Metadata
    # Upsert a {Harvesting::Contributions::Proxy} for a {HarvestEntity}.
    #
    # @api private
    # @see Harvesting::Metadata::UpsertContributionProxies
    class UpsertContributionProxy
      include Dry::Monads[:do, :result]
      include MeruAPI::Deps[
        upsert_contributor: "harvesting.contributors.upsert",
        upsert_contribution: "harvesting.contributions.upsert",
      ]

      # @param [HarvestEntity] harvest_entity
      # @param [Harvesting::Contributions::Proxy] contribution_proxy
      # @return [Dry::Monads::Success(HarvestContribution)]
      def call(harvest_entity, contribution_proxy)
        harvest_contributor = yield upsert_contributor.call(*contribution_proxy.contributor.to_upsert)

        upsert_contribution.(harvest_entity, harvest_contributor, **contribution_proxy.options)
      end
    end
  end
end
