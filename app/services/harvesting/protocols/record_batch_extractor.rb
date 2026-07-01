# frozen_string_literal: true

module Harvesting
  module Protocols
    # This fetches multiple records in batches for a given {HarvestAttempt}
    # and will create or update {HarvestRecord}s for its {HarvestSource}.
    #
    # @abstract
    class RecordBatchExtractor
      include Harvesting::Protocols::CursorBasedBatchEnumerator

      include Dry::Effects::Handler.Interrupt(:no_records, as: :catch_no_records)
      include Dry::Effects.Interrupt(:no_records)

      param :harvest_attempt, ::Harvesting::Types::Attempt

      delegate :harvest_mapping, :harvest_set, :harvest_source, to: :harvest_attempt

      # @return [Harvesting::Extraction::Context]
      attr_reader :context

      # @return [HarvestConfiguration]
      attr_reader :harvest_configuration

      # @return [HarvestMetadataFormat]
      attr_reader :metadata_format

      # @return [Harvesting::Attempts::RecordExtractionProgress]
      attr_reader :progress

      # @return [Harvesting::Protocols::Context]
      attr_reader :protocol

      around_enumeration :provide_harvest_source!
      around_enumeration :provide_harvest_mapping!
      around_enumeration :provide_harvest_attempt!
      around_enumeration :provide_harvest_configuration!
      around_enumeration :provide_metadata_format!

      around_enumeration :with_no_records!
      around_enumeration :track_attempt_state!

      def initialize(...)
        super

        set_up!

        # simplecov:disable
        progress.reset! if provided_cursor.blank?
        # simplecov:enable
      end

      def call
        each do |harvest_record, _|
          logger.trace "Extracted #{harvest_record.identifier}"
        end

        Success()
      end

      private

      # @return [void]
      def set_up!
        @harvest_configuration = harvest_attempt.harvest_configuration || harvest_attempt.create_configuration!

        @context = harvest_configuration.build_extraction_context

        @metadata_format = context.metadata_format

        @progress = context.progress

        @protocol = context.protocol
      end

      # @param [Object] batch
      # @return [<HarvestRecord>]
      def process_batch(batch)
        protocol.process_record_batch.(batch).value_or([])
      end

      # @param [Object] batch
      # @return [void]
      def pre_process!(batch)
        progress.batches!

        record_count = batch_count_for batch

        no_records if record_count == 0

        progress.records! record_count

        on_batch batch
      end

      # @param [<HarvestRecord>] processed
      # @return [void]
      def post_process!(processed)
        logger.debug "Batch complete"

        progress.processed! processed.size

        halt_enumeration if progress.should_stop?
      end

      # @return [void]
      def track_attempt_state!
        harvest_attempt.transition_to(:executing)

        yield
      ensure
        harvest_attempt.transition_to(:extracted)
      end

      # @param [Integer] total
      # @return [void]
      def update_total_record_count!(total)
        return if total.blank?

        return if total == harvest_attempt.record_count

        harvest_attempt.update_column :record_count, total
      end

      # @return [void]
      def with_no_records!
        interrupted, _ = catch_no_records do
          yield
        end

        logger.warn "No records to extract" if interrupted
      end
    end
  end
end
