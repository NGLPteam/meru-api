# frozen_string_literal: true

module Harvesting
  module Records
    # Upsert root entities for a {HarvestRecord} and merge in errors (if any).
    class UpsertEntities
      include Dry::Monads[:result]
      include MeruAPI::Deps[
        upsert_entity: "harvesting.entities.upsert",
      ]

      # @param [HarvestRecord] harvest_record
      # @return [Dry::Monads::Result]
      def call(harvest_record)
        Schemas::Orderings.with_asynchronous_refresh do
          harvest_record.harvest_entities.roots.find_each do |root_entity|
            upsert_entity.call(root_entity).or do |reason|
              harvest_record.log_harvest_error!(*root_entity.to_failed_upsert(reason))
            end
          end
        end

        Success()
      end
    end
  end
end
