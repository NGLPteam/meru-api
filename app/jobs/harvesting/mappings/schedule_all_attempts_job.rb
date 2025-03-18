# frozen_string_literal: true

module Harvesting
  module Mappings
    # @see Harvesting::Mappings::AttemptsScheduler
    # @see Harvesting::Mappings::ScheduleAttempts
    # @see Harvesting::Mappings::ScheduleAttemptsJob
    class ScheduleAllAttemptsJob < ApplicationJob
      include JobIteration::Iteration

      queue_as :maintenance

      good_job_control_concurrency_with(
        total_limit: 1,
        key: -> { "#{self.class.name}-#{queue_name}" }
      )

      # @param [String] cursor
      # @return [void]
      def build_enumerator(cursor:)
        enumerator_builder.active_record_on_records(
          HarvestMapping.scheduled,
          cursor:,
        )
      end

      # @param [HarvestMapping] harvest_mapping
      # @return [void]
      def each_iteration(harvest_mapping)
        Harvesting::Mappings::ScheduleAttemptsJob.perform_later(harvest_mapping)
      end
    end
  end
end
