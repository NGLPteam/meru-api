# frozen_string_literal: true

module Harvesting
  module Records
    # @see Harvesting::Records::EnqueueRootEntities
    class RootEntitiesEnqueuer < Support::HookBased::Actor
      include Harvesting::Middleware::ProvidesHarvestData
      include Harvesting::WithLogger
      include Dry::Initializer[undefined: false].define -> do
        param :harvest_record, Harvesting::Types::Record
      end

      standard_execution!

      delegate :harvest_configuration, :harvest_source, to: :harvest_record

      delegate :harvest_attempt, to: :harvest_configuration, allow_nil: true

      around_execute :provide_harvest_record!

      around_execute :provide_harvest_configuration!

      around_execute :provide_harvest_attempt!

      around_execute :provide_harvest_source!

      # @return [GoodJob::Batch]
      attr_reader :batch

      # Root harvest entities for the provided record.
      #
      # @return [<HarvestEntity>]
      attr_reader :harvest_entities

      # @return [Dry::Monads::Success(void)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield enqueue_roots!
        end

        Success()
      end

      wrapped_hook! def prepare
        @batch = build_batch

        @harvest_entities = harvest_record.harvest_entities.roots.to_a

        @batch_options = build_batch_options

        super
      end

      wrapped_hook! def enqueue_roots
        # :nocov:
        return super unless harvest_entities.present?
        # :nocov:

        batch.add do
          harvest_entities.each do |harvest_entity|
            Harvesting::Entities::UpsertJob.perform_later harvest_entity
          end
        end

        batch.enqueue(**@batch_options)

        super
      end

      private

      def build_batch
        batch = GoodJob::Batch.new

        batch.description = "#{harvest_record.inspect} upsert root entities batch"

        return batch
      end

      def build_batch_options
        {
          harvest_attempt:,
          harvest_record:,
          on_finish: nil,
        }
      end
    end
  end
end
