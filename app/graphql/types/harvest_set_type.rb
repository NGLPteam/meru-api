# frozen_string_literal: true

module Types
  # @see HarvestSet
  class HarvestSetType < Types::BaseModel
    description <<~TEXT
    The concept of a "set" within a given `HarvestSource`. It can be used in order to fetch
    a subset of data with a `HarvestMapping`. These are not created directly in Meru, but
    instead are fetched by the `HarvestSource` and internally managed based on its `protocol`.
    TEXT

    field :identifier, String, null: false do
      description <<~TEXT
      A unique, machine-readable string that identifies the set for the specific source.
      TEXT
    end

    field :name, String, null: false do
      description <<~TEXT
      A human-readable name that describes the set (if available).
      TEXT
    end

    field :description, String, null: true do
      description <<~TEXT
      An optional description for the set (if available).
      TEXT
    end

    field :harvest_source, "Types::HarvestSourceType", null: false do
      description <<~TEXT
      The source for the harvest set.
      TEXT
    end

    load_association! :harvest_source
  end
end
