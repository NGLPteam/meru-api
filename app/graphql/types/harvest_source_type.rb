# frozen_string_literal: true

module Types
  # @see HarvestSource
  class HarvestSourceType < Types::BaseModel
    description <<~TEXT
    A source from which to harvest entities.

    It can produce a `HarvestAttempt`.
    TEXT

    implements Types::HarvestAttemptableType
    implements Types::HasHarvestExtractionMappingTemplateType
    implements Types::HasHarvestMetadataFormatType
    implements Types::HasHarvestOptionsType
    implements Types::QueriesHarvestMessage

    field :name, String, null: false do
      description <<~TEXT
      A unique name for the source. Purely descriptive.
      TEXT
    end

    field :identifier, String, null: false do
      description <<~TEXT
      A unique, machine-readable identifier. Requirements:

      * At least three characters: alphanumeric, hyphens, underscores
      * All lowercase
      * No whitespace
      * No consecutive hyphens nor underscores.

      Cannot be changed once created. To reuse an identifier, the original source
      must be destroyed.
      TEXT
    end

    field :protocol, Types::HarvestProtocolType, null: false do
      description <<~TEXT
      The protocol for this source.

      Cannot be changed once created.
      TEXT
    end

    field :base_url, String, null: false do
      description <<~TEXT
      The URL to fetch from. It should be just the base URL, without any OAI verbs or similar.
      TEXT
    end

    field :description, String, null: true do
      description <<~TEXT
      An optional, wordier description for the source that may offer insight as to its intended
      purpose within the installation.
      TEXT
    end

    field :harvest_attempts, resolver: ::Resolvers::HarvestAttemptResolver do
      description <<~TEXT
      Attempts produced by this source.
      TEXT
    end

    field :harvest_mappings, resolver: ::Resolvers::HarvestMappingResolver do
      description <<~TEXT
      Mappings associated with the harvest source.
      TEXT
    end

    field :harvest_metadata_mappings, resolver: ::Resolvers::HarvestMetadataMappingResolver do
      description <<~TEXT
      Metadata mappings used for advanced features that allow matching patterns to existing harvest targets.
      TEXT
    end

    field :harvest_records, resolver: ::Resolvers::HarvestRecordResolver do
      description <<~TEXT
      Records associated with this source.
      TEXT
    end

    field :harvest_sets, resolver: ::Resolvers::HarvestSetResolver do
      description <<~TEXT
      Sets associated with the harvest source.

      A single source may have thousands of sets associated with it,
      so it must be paginated.
      TEXT
    end

    field :status, Types::HarvestSourceStatusType, null: false do
      description <<~TEXT
      An enum that describes the functional state for harvest sources.
      TEXT
    end
  end
end
