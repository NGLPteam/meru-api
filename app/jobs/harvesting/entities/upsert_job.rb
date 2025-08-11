# frozen_string_literal: true

module Harvesting
  module Entities
    # @see Harvesting::Entities::Upsert
    # @see Harvesting::Entities::Upserter
    class UpsertJob < ApplicationJob
      BASE_PRIORITY = 400

      queue_as :harvesting

      queue_with_priority do
        harvest_entity = arguments.first

        base_depth = harvest_entity.try(:depth) || 1

        BASE_PRIORITY + base_depth
      end

      # @param [HarvestEntity] harvest_entity
      # @return [void]
      def perform(harvest_entity)
        call_operation! "harvesting.entities.upsert", harvest_entity
      end
    end
  end
end
