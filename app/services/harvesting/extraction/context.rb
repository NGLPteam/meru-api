# frozen_string_literal: true

module Harvesting
  module Extraction
    # A context wrapping a {HarvestConfiguration}.
    class Context
      include Dry::Initializer[undefined: false].define -> do
        param :harvest_configuration, Harvesting::Types::Configuration
      end

      delegate :harvest_attempt, :harvest_set, :harvest_mapping, :harvest_source, :extraction_mapping_template,
        to: :harvest_configuration

      # @return [Boolean]
      attr_reader :has_metadata_mappings

      alias has_metadata_mappings? has_metadata_mappings

      # @return [Harvesting::Extraction::Mapping]
      attr_reader :mapping

      # @return [<Symbol>]
      attr_reader :mapping_errors

      # @return [HarvestMetadataFormat]
      attr_reader :metadata_format

      # @return [ActiveRecord::Relation<HarvestMetadataMapping>]
      attr_reader :metadata_mappings

      # @return [Harvesting::Configurations::Progress, nil]
      attr_reader :progress

      # @return [Harvesting::Protocols::Context]
      attr_reader :protocol

      # @return [Boolean]
      attr_reader :use_metadata_mappings

      alias use_metadata_mappings? use_metadata_mappings

      def initialize(...)
        super

        parse_mapping_template!

        @metadata_format = HarvestMetadataFormat.find harvest_configuration.metadata_format

        @metadata_mappings = harvest_configuration.metadata_mappings_for_extraction

        @progress = Harvesting::Configurations::Progress.new(harvest_configuration)

        @protocol = harvest_source.build_protocol_context

        @use_metadata_mappings = harvest_configuration.use_metadata_mappings?

        @has_metadata_mappings = use_metadata_mappings? && metadata_mappings.exists?
      end

      private

      # @return [void]
      def parse_mapping_template!
        @mapping = nil
        @mapping_errors = []

        MeruAPI::Container["harvesting.extraction.validate_mapping_template"].(extraction_mapping_template) do |m|
          m.success do |mapping|
            @mapping = mapping
          end

          m.failure(:invalid_mapping_template) do |_, errors|
            @mapping_errors = errors
          end

          m.failure do
            # :nocov:
            # Fallback error case.
            @mapping_errors << "Something went wrong"
            # :nocov:
          end
        end

        # :nocov:
        raise Harvesting::Error, "Invalid extraction mapping template: #{@mapping_errors.join(', ')}" if @mapping.nil? && @mapping_errors.any?
        # :nocov:
      end
    end
  end
end
