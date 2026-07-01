# frozen_string_literal: true

module Harvesting
  module Configurations
    # @see Harvesting::Configurations::Create
    class Creator < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :configurable, Harvesting::Types::Configurable

        option :harvest_set, Harvesting::Types::Set.optional, as: :provided_harvest_set, optional: true

        option :target_entity, Harvesting::Types::Target.optional, as: :provided_target_entity, optional: true

        option :extraction_mapping_template, Types::String.optional, optional: true, as: :provided_extraction_mapping_template

        option :force, Harvesting::Types::Bool, default: proc { false }
      end

      standard_execution!

      delegate :list_options, :read_options, :format_options, :mapping_options, to: :configurable

      # @return [String]
      attr_reader :extraction_mapping_template

      # @return [HarvestConfiguration]
      attr_reader :harvest_configuration

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

      # @return [Dry::Monads::Success(HarvestConfiguration)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield determine_models!

          yield maybe_assign_and_persist!
        end

        Success harvest_configuration
      end

      wrapped_hook! def prepare
        @extraction_mapping_template = nil
        @harvest_configuration = nil
        @harvest_source = nil
        @harvest_mapping = nil
        @metadata_format = nil
        @target_entity = nil

        @shared_tuple = nil

        super
      end

      wrapped_hook! def determine_models
        case configurable
        when HarvestAttempt
          @harvest_mapping = configurable.harvest_mapping
          @harvest_set = configurable.harvest_set
          @harvest_source = configurable.harvest_source
          @target_entity = configurable.target_entity
        when HarvestSource
          return Failure(:missing_target_entity_for_source) if provided_target_entity.blank?

          @harvest_source = configurable
          @harvest_set = provided_harvest_set
          @target_entity = provided_target_entity
        else
          # simplecov:disable
          raise "Invalid configurable: #{configurable.inspect}"
          # simplecov:enable
        end

        @extraction_mapping_template = provided_extraction_mapping_template.presence || configurable.extraction_mapping_template

        @metadata_format = configurable.metadata_format

        @shared_tuple = build_shared_tuple

        @shared_tuple[:list_options] = configurable.list_options
        @shared_tuple[:read_options] = configurable.read_options

        @harvest_configuration = yield find_or_initialize_configuration

        super
      end

      wrapped_hook! def maybe_assign_and_persist
        return super unless force || harvest_configuration.new_record?

        harvest_configuration.assign_attributes(@shared_tuple)

        harvest_configuration.save!

        super
      end

      private

      # @return [Dry::Monads::Success(HarvestConfiguration)]
      def find_or_initialize_configuration
        case configurable
        when HarvestAttempt
          Success configurable.harvest_configuration || configurable.build_harvest_configuration
        when HarvestSource
          found = configurable.harvest_configurations.where(@shared_tuple).first_or_initialize

          Success found
        else
          # simplecov:disable
          raise "Invalid configurable: #{configurable.inspect}"
          # simplecov:enable
        end
      end

      def build_shared_tuple
        {
          harvest_set:,
          harvest_source:,
          target_entity:,
          metadata_format:,
          extraction_mapping_template:,

          format_options:,
          list_options:,
          read_options:,
          mapping_options:
        }
      end
    end
  end
end
