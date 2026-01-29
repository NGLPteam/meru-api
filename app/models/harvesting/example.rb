# frozen_string_literal: true

module Harvesting
  class Example < Support::FrozenRecordHelpers::AbstractRecord
    include Dry::Core::Constants
    include Harvesting::Frozen::HasProtocolAndMetadata

    protocol_and_metadata_optional!

    TEMPLATE_ROOT = Rails.root.join("lib", "harvesting", "examples")

    schema!(types: ::Harvesting::Frozen::TypeRegistry) do
      required(:id).filled(:string)
      required(:name).filled(:string)
      required(:default).value(:bool)
      required(:generic).value(:bool)
      required(:protocol_name).maybe(:protocol_name)
      required(:metadata_format_name).maybe(:metadata_format_name)
      required(:protocol).maybe(:protocol)
      required(:metadata_format).maybe(:metadata_format)
      required(:description).maybe(:string)
      required(:schema_declarations).array(:schema_declaration)
      required(:schema_versions).array(:schema_version)
      required(:extraction_mapping).value(:extraction_mapping)
      required(:template).filled(:string)
    end

    add_index :id, unique: true

    self.primary_key = :id

    default_attributes!(
      default: false,
      description: nil,
      metadata_format_name: nil,
      protocol_name: nil,
    )

    scope :default, -> { where(default: true) }
    scope :generic, -> { where(generic: true) }

    alias_attribute :extraction_mapping_template, :template

    calculates! :generic do |record|
      record["protocol_name"].blank? && record["metadata_format_name"].blank?
    end

    calculates! :template do |record|
      path = TEMPLATE_ROOT.join(record["id"], "template.xml")

      path.read
    end

    calculates! :extraction_mapping do |record|
      Harvesting::Extraction::Mapping.from_xml(record["template"])
    end

    calculates! :schema_declarations do |record|
      record["extraction_mapping"].schema_declarations
    end

    calculates! :schema_versions do |record|
      Array(record["schema_declarations"]).map { SchemaVersion[_1] }
    rescue ActiveRecord::RecordNotFound, ActiveRecord::StatementInvalid
      # :nocov:
      # Order of operations issue that only appears on CI.
      EMPTY_ARRAY
      # :nocov:
    end

    class << self
      # @param [Harvesting::Types::ProtocolName] protocol_name
      # @param [Harvesting::Types::MetadataFormatName] metadata_format
      # @return [Harvesting::Example]
      def default_for(protocol_name, metadata_format_name)
        default_scope_for(protocol_name, metadata_format_name).first
      end

      # @param [Harvesting::Types::ProtocolName] protocol_name
      # @param [Harvesting::Types::MetadataFormatName] metadata_format
      # @return [FrozenRecord::Scope]
      def default_scope_for(protocol_name, metadata_format_name)
        by_protocol(protocol_name).by_metadata_format(metadata_format_name).default
      end

      # @param [Harvesting::Types::ProtocolName] protocol_name
      # @param [Harvesting::Types::MetadataFormatName] metadata_format
      # @return [String, nil]
      def default_template_for(protocol_name, metadata_format_name)
        default_for(protocol_name, metadata_format_name).try(:extraction_mapping_template)
      end

      # @param [Harvesting::Types::ProtocolName] protocol_name
      # @param [Harvesting::Types::MetadataFormatName] metadata_format
      # @return [String]
      def default_or_generic_template_for(protocol_name, metadata_format_name)
        default = default_template_for(protocol_name, metadata_format_name)

        default.presence || find("empty").extraction_mapping_template
      end

      # @return [FrozenRecord::Scope]
      def for_graphql(generic: false, metadata_format: nil, protocol: nil)
        base_scope =
          if generic
            all.generic
          else
            by_protocol(protocol).by_metadata_format(metadata_format)
          end

        base_scope.all
      end

      # @return [String]
      def template_for(id)
        find(id).extraction_mapping_template
      end
    end
  end
end
