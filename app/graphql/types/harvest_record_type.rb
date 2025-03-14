# frozen_string_literal: true

module Types
  # @see HarvestRecord
  class HarvestRecordType < Types::AbstractModel
    description <<~TEXT
    An object representing a single record in the `HarvestSource`.
    It can produce one or more harvest entities.
    TEXT

    implements Types::HasHarvestErrorsType
    implements Types::HasHarvestMetadataFormatType
    implements Types::QueriesHarvestMessage

    field :identifier, String, null: false do
      description <<~TEXT
      A unique identifier for the record within the `HarvestSource`.
      TEXT
    end

    field :status, Types::HarvestRecordStatusType, null: false do
      description <<~TEXT
      The status of the record.
      TEXT
    end

    field :harvest_entities, [::Types::HarvestEntityType, { null: false }], null: false do
      description <<~TEXT
      Staged entities that were extracted from this record.
      TEXT
    end

    field :entity_count, Integer, null: true do
      description <<~TEXT
      The number of entities this record can/will produce (if available).
      TEXT
    end

    field :raw_source, String, null: true do
      description <<~TEXT
      The raw source extracted from the protocol.

      When rendering in the frontend, this should be in some sort of fixed-width font / code view,
      as it will be JSON, XML, or similar types of data.
      TEXT
    end

    field :raw_metadata_source, String, null: true do
      description <<~TEXT
      The raw metadata extracted from `rawSource`, with minimal processing applied.

      When rendering in the frontend, this should be in some sort of fixed-width font / code view,
      as it will be JSON, XML, or similar types of data.
      TEXT
    end

    load_association! :harvest_entities
  end
end
