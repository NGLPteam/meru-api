# frozen_string_literal: true

module Harvesting
  module Records
    # @see Harvesting::Records::EnqueueRootEntities
    # @see Harvesting::Records::RootEntitiesEnqueuer
    class EnqueueRootEntitiesJob < ApplicationJob
      queue_as :harvesting

      queue_with_priority 350

      # @param [HarvestRecord] harvest_record
      # @return [void]
      def perform(harvest_record)
        call_operation! "harvesting.records.enqueue_root_entities", harvest_record
      end
    end
  end
end
