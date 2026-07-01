# frozen_string_literal: true

module Harvesting
  module Attempts
    # @see Harvesting::Attempts::Create
    class Creator < Support::HookBased::Actor
      include AfterCommitEverywhere
      include Dry::Initializer[undefined: false].define -> do
        param :attemptable, Types::Attemptable

        option :harvest_set, Harvesting::Types::Set.optional, as: :provided_harvest_set, optional: true

        option :target_entity, Harvesting::Types::Target.optional, as: :provided_target_entity, optional: true

        option :occurrence, Harvesting::Types.Instance(::Harvesting::Schedules::Occurrence).optional, optional: true

        option :mode, Types::String, default: -> { occurrence.present? ? "scheduled" : "manual" }

        option :note, Types::String, default: -> { "A #{mode} attempt for a #{attemptable.model_name.human}" }

        option :extraction_mapping_template, Types::String.optional, optional: true, as: :provided_extraction_mapping_template

        option :enqueue_extraction, Types::Bool, default: proc { false }
      end

      standard_execution!

      delegate :scheduling_key, :scheduled_at, to: :occurrence, allow_nil: true

      # @return [String]
      attr_reader :extraction_mapping_template

      # @return [HarvestAttempt]
      attr_reader :harvest_attempt

      # @return [HarvestMapping, nil]
      attr_reader :harvest_mapping

      # @return [HarvestSet, nil]
      attr_reader :harvest_set

      # @return [HarvestSource]
      attr_reader :harvest_source

      # @return [Harvesting::Types::MetadataFormatName]
      attr_reader :metadata_format

      # @return [HarvestTarget]
      attr_reader :target_entity

      # @return [Dry::Monads::Success(HarvestAttempt)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield determine_models!

          yield assign_data!

          yield persist_attempt!
        end

        Success harvest_attempt
      end

      wrapped_hook! def prepare
        @extraction_mapping_template = nil
        @harvest_attempt = build_or_find_harvest_attempt
        @harvest_source = nil
        @harvest_mapping = nil
        @metadata_format = nil
        @target_entity = nil

        super
      end

      wrapped_hook! def determine_models
        case attemptable
        when HarvestMapping
          @harvest_mapping = attemptable
          @harvest_set = attemptable.harvest_set
          @harvest_source = attemptable.harvest_source
          @target_entity = provided_target_entity || attemptable.target_entity
        when HarvestSource
          return Failure(:missing_target_entity_for_source) if provided_target_entity.blank?

          @harvest_source = attemptable
          @harvest_set = provided_harvest_set
          @target_entity = provided_target_entity
        else
          # simplecov:disable
          raise "Invalid attemptable: #{attemptable.inspect}"
          # simplecov:enable
        end

        @extraction_mapping_template = provided_extraction_mapping_template.presence || attemptable.extraction_mapping_template

        @metadata_format = attemptable.metadata_format

        super
      end

      wrapped_hook! def assign_data
        harvest_attempt.assign_attributes(
          extraction_mapping_template:,
          harvest_source:,
          harvest_mapping:,
          harvest_set:,
          metadata_format:,
          target_entity:
        )

        attemptable.modify_attempt_metadata! harvest_attempt.metadata

        super
      end

      wrapped_hook! def persist_attempt
        # This should never reasonably fail.
        harvest_attempt.save!

        yield harvest_attempt.create_configuration(force: scheduled_for_mapping?)

        harvest_attempt.transition_to(:scheduled) if scheduled_for_mapping?

        after_commit do
          Harvesting::ExtractRecordsJob.perform_later(harvest_attempt) if enqueue_extraction
        end

        super
      end

      private

      def build_or_find_harvest_attempt
        return HarvestAttempt.new(mode:, note:) unless scheduled_for_mapping?

        attemptable.harvest_attempts.where(scheduling_key:).first_or_initialize do |ha|
          ha.assign_attributes(mode:, note:, scheduled_at:)
        end
      end

      def scheduled_for_mapping?
        occurrence.present? && attemptable.kind_of?(HarvestMapping)
      end
    end
  end
end
