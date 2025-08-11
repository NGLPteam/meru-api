# frozen_string_literal: true

module Harvesting
  module Records
    # @see Harvesting::Records::ExtractEntities
    class ExtractEntitiesJob < ApplicationJob
      queue_as :harvesting

      queue_with_priority 300

      # @param [HarvestRecord] harvest_record
      # @return [void]
      def perform(harvest_record)
        call_operation! "harvesting.records.extract_entities", harvest_record

        Harvesting::Records::EnqueueRootEntitiesJob.perform_later(harvest_record) if harvest_record.with_active_status?
      end
    end
  end
end
