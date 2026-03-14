# frozen_string_literal: true

module Harvesting
  module Attempts
    # @see Harvesting::Actions::ExtractRecords
    class ExtractRecords
      include Harvesting::WithLogger
      include Dry::Monads[:result]

      # @param [HarvestAttempt] harvest_attempt
      # @return [Dry::Monads::Success(Integer)] the count of records harvested
      def call(harvest_attempt, cursor: nil)
        protocol = harvest_attempt.build_protocol_context

        protocol.extract_records_for(harvest_attempt)

        Success harvest_attempt.harvest_records.count
      end
    end
  end
end
