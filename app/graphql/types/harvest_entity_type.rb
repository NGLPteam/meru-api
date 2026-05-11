# frozen_string_literal: true

module Types
  # @see HarvestEntity
  class HarvestEntityType < Types::BaseModel
    description <<~TEXT
    A staged entity extracted from a `HarvestRecord`, that
    can then be associated to an actual entity by the
    harvesting process.
    TEXT

    implements Types::QueriesHarvestMessage

    field :parent, self, null: true do
      description <<~TEXT
      The parent staged entity (if applicable).
      TEXT
    end

    field :entity, Types::EntityType, null: true do
      description <<~TEXT
      The real entity this is associated with (if available).
      TEXT
    end

    field :schema_version, Types::SchemaVersionType, null: true do
      description <<~TEXT
      The schema version that this will use (if available).
      TEXT
    end

    field :identifier, String, null: false do
      description <<~TEXT
      A unique identifier for the staged entity within the context of its `HarvestRecord`.
      TEXT
    end

    field :relative_depth, Integer, null: false, method: :depth do
      description <<~TEXT
      The relative depth of the staged entity (based on the attempt's `targetEntity`).
      TEXT
    end

    field :leaf, Boolean, null: false, method: :leaf? do
      description <<~TEXT
      Whether this staged entity is a leaf (has no children).
      TEXT
    end

    field :root, Boolean, null: false, method: :root? do
      description <<~TEXT
      Whether this staged entity is a root (has no parent).
      TEXT
    end

    load_association! :entity
    load_association! :parent
    load_association! :schema_version
  end
end
