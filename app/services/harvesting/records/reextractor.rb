# frozen_string_literal: true

module Harvesting
  module Records
    # @see Harvesting::Records::Reextract
    class Reextractor < Support::HookBased::Actor
      include Harvesting::Middleware::ProvidesHarvestData
      include Dry::Initializer[undefined: false].define -> do
        param :harvest_record, ::Harvesting::Types::Record
      end

      standard_execution!

      delegate :harvest_configuration, :identifier, :metadata_format, to: :harvest_record

      # This can become nil upon re-extraction if the record was deleted.
      #
      # @return [HarvestRecord, nil]
      attr_reader :extracted_record

      # @return [Harvesting::Protocols::Context]
      attr_reader :protocol

      # @return [Dry::Monads::Success(HarvestRecord)]
      # @return [Dry::Monads::Success(nil)] if the re-extraction marked the record as deleted
      def call
        run_callbacks :execute do
          yield prepare!

          yield reextract!
        end

        Success extracted_record
      end

      wrapped_hook! def prepare
        @extracted_record = nil

        @protocol = harvest_record.build_protocol_context

        super
      end

      wrapped_hook! def reextract
        protocol.extract_record.call(identifier, metadata_format)

        @extracted_record = harvest_record.reload
      rescue ActiveRecord::RecordNotFound
        # If re-extracting deleted the record, that's okay
        # simplecov:disable
        super
        # simplecov:enable
      else
        super
      end

      around_reextract :provide_harvest_configuration!
    end
  end
end
