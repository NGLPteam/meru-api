# frozen_string_literal: true

module Types
  # @see HarvestMetadataMapping
  class HarvestMetadataMappingType < Types::BaseModel
    description <<~TEXT
    An advanced definition that allows mapping specific existing entities to act as parents
    for certain harvested entities, based on their metadata matching a specific mapping.
    TEXT

    field :field, ::Types::HarvestMetadataMappingFieldType, null: false do
      description <<~TEXT
      Which "field" this should try to match its `pattern` against.
      TEXT
    end

    field :pattern, String, null: false do
      description <<~TEXT
      A regular expression / pattern to match against. Must be written to support postgres regular expressions,
      which are more limited than most modern languages but follow the ANSI spec as much as possible.
      TEXT
    end

    field :target_entity, Types::HarvestTargetType, null: false do
      description <<~TEXT
      The entity that will act as the parent when this metadata mapping is matched.
      TEXT
    end

    load_association! :target_entity
  end
end
