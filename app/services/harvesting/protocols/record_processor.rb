# frozen_string_literal: true

module Harvesting
  module Protocols
    # @abstract
    class RecordProcessor
      include ::Utility::DefinesAbstractMethods
      include Dry::Monads[:result, :do]
      include Dry::Effects.Interrupt(:deleted_record)
      include Dry::Effects.Reader(:harvest_attempt, default: nil)
      include Dry::Effects.Reader(:harvest_configuration)
      include Dry::Effects.Reader(:harvest_mapping, default: nil)
      include Dry::Effects.Reader(:metadata_format)
      include Harvesting::WithLogger

      include Dry::Initializer[undefined: false].define -> do
        param :protocol, Harvesting::Types.Instance(::Harvesting::Protocols::Context)
      end

      delegate :deleted?, :harvest_source, :record_identifier_for, :skip?, to: :protocol

      prepend Harvesting::HushActiveRecord

      # @param [Object] raw_record
      # @return [Dry::Monads::Success(HarvestRecord)]
      def call(raw_record)
        if exists?(raw_record)
          handle_existing! raw_record
        else
          handle_deleted! raw_record
        end
      end

      private

      # @param [Object] raw_record
      def exists?(raw_record)
        !(skip?(raw_record) || deleted?(raw_record))
      end

      # @!group Hooks

      # @param [HarvestRecord] record
      # @param [Object] raw_record
      # @return [Dry::Monads::Result]
      def adjust_record!(record, raw_record)
        # :nocov:
        Success()
        # :nocov:
      end

      # @!endgroup

      # @!group Scoping

      # @param [Object] raw_record
      # @return [Dry::Monads::Success(ActiveRecord::Relation<HarvestRecord>)]
      def scope_for(raw_record)
        identifier = yield record_identifier_for raw_record

        Success harvest_source.harvest_records.by_identifier(identifier)
      end

      # @param [Object] raw_record
      # @return [Dry::Monads::Success(HarvestRecord)]
      def record_for(raw_record)
        scope_for(raw_record).fmap(&:first_or_initialize)
      end

      # @!endgroup

      # @!group Handlers

      # @param [Object] raw_record
      # @return [Dry::Monads::Success]
      def handle_existing!(raw_record)
        record = yield record_for raw_record

        identifier = yield record_identifier_for raw_record

        logger.log "Processing record #{identifier.inspect}"

        record.metadata_format = metadata_format.name

        yield extract_source! record, raw_record
        yield extract_metadata! record, raw_record
        yield adjust_record! record, raw_record

        assign_configuration! record

        # This should not reasonably fail.
        record.save!

        record.reset_status!

        maybe_link! record

        Success record
      end

      # @param [Object] raw_record
      # @return [void]
      def handle_deleted!(raw_record)
        identifier = yield record_identifier_for raw_record

        scope = yield scope_for(raw_record)

        scope.update_all(status: :deleted)

        logger.log "Received deleted record identifier: #{identifier.inspect}"

        deleted_record
      end

      # @!endgroup

      # @!group Steps

      # @param [HarvestRecord] record
      # @param [Object] raw_record
      # @return [Dry::Monads::Result]
      def extract_source!(record, raw_record)
        record.raw_source = yield protocol.extract_raw_source(raw_record)

        Success()
      end

      # @param [HarvestRecord] record
      # @param [Object] raw_record
      # @return [Dry::Monads::Result]
      def extract_metadata!(record, raw_record)
        raw_metadata_source = yield protocol.extract_raw_metadata(raw_record)

        record.raw_metadata_source = raw_metadata_source

        Success()
      end

      # @!endgroup

      # @param [HarvestRecord] record
      # @return [void]
      def assign_configuration!(record)
        if harvest_attempt.present?
          record.harvest_configuration = harvest_configuration
        else
          record.harvest_configuration ||= harvest_configuration
        end
      end

      # @param [HarvestRecord] record
      # @return [void]
      def maybe_link!(record)
        link_with_attempt!(record)
        link_with_mapping!(record)
      end

      # @param [HarvestRecord] record
      # @return [void]
      def link_with_attempt!(record)
        # :nocov:
        return if harvest_attempt.blank?

        harvest_attempt.connect_record!(record)
        # :nocov:
      end

      # @param [HarvestRecord] record
      # @return [void]
      def link_with_mapping!(record)
        # :nocov:
        return if harvest_mapping.blank?

        tuple = { harvest_mapping_id: harvest_mapping.id, harvest_record_id: record.id }

        HarvestMappingRecordLink.upsert(tuple, unique_by: %i[harvest_mapping_id harvest_record_id])
        # :nocov:
      end
    end
  end
end
