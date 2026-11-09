# frozen_string_literal: true

module Harvesting
  module Mappings
    # @see Harvesting::Mappings::AttemptsScheduler
    # @see Harvesting::Mappings::ScheduleAttempts
    # @see Harvesting::Mappings::ScheduleAllAttemptsJob
    class ScheduleAttemptsJob < ApplicationJob
      queue_as :default

      unique_job!(by: :queue_first_id)

      # @param [HarvestMapping] harvest_mapping
      # @return [void]
      def perform(harvest_mapping)
        call_operation!("harvesting.mappings.schedule_attempts", harvest_mapping)
      end
    end
  end
end
