# frozen_string_literal: true

module Harvesting
  module Attempts
    # @see HarvestAttempt.to_enqueue_for_next_hour
    class EnqueueScheduledJob < ApplicationJob
      include JobIteration::Iteration

      queue_as :maintenance

      unique_job!(by: :queue)

      # @param [String] cursor
      # @return [void]
      def build_enumerator(cursor:)
        enumerator_builder.active_record_on_records(
          HarvestAttempt.to_enqueue_for_next_hour,
          cursor:,
        )
      end

      # @see Harvesting::ExtractRecordsJob
      # @param [HarvestAttempt] harvest_attempt
      # @return [void]
      def each_iteration(harvest_attempt)
        wait_until = harvest_attempt.scheduled_at

        Harvesting::ExtractRecordsJob.set(wait_until:).perform_later(harvest_attempt)
      end
    end
  end
end
