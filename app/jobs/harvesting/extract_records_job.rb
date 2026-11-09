# frozen_string_literal: true

module Harvesting
  # @see Harvesting::Protocols::BatchRecordExtractor
  class ExtractRecordsJob < ApplicationJob
    include JobIteration::Iteration

    queue_as :extraction

    unique_job! by: :queue_first_id

    # @param [HarvestAttempt] harvest_attempt
    # @return [void]
    def build_enumerator(harvest_attempt, cursor:)
      protocol = harvest_attempt.build_protocol_context

      enum = protocol.record_enumerator_for(harvest_attempt, cursor:)

      # @see https://github.com/Shopify/job-iteration/blob/2065db0bbd461a990e13aa9bb56f86da294c584c/lib/job-iteration/enumerator_builder.rb#L42
      enumerator_builder.wrap(enumerator_builder, enum)
    end

    # @see Harvesting::Records::ExtractEntitiesJob
    # @param [HarvestRecord] harvest_record
    # @param [HarvestAttempt] _harvest_attempt
    # @return [void]
    def each_iteration(harvest_record, _harvest_attempt)
      Harvesting::Records::ExtractEntitiesJob.perform_later harvest_record
    end
  end
end
