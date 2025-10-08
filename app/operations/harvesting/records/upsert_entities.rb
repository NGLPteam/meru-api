# frozen_string_literal: true

module Harvesting
  module Records
    # Upsert root entities for a {HarvestRecord} and merge in errors (if any).
    #
    # @deprecated
    class UpsertEntities
      include Dry::Monads[:result]

      # @param [HarvestRecord] harvest_record
      # @return [Dry::Monads::Result]
      def call(harvest_record)
        Schemas::Orderings.with_asynchronous_refresh do
          harvest_record.harvest_entities.roots.find_each do |root_entity|
            root_entity.upsert(inline: true).or do |reason|
              logger.error("Failed to upsert entities for record", tags: %i[failed_entity_upsert], reason:)
            end
          end
        end

        Success()
      end
    end
  end
end
