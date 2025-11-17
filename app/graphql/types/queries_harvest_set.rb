# frozen_string_literal: true

module Types
  # An interface for querying {HarvestSet}.
  module QueriesHarvestSet
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `HarvestSet` records.

    To query a collection of harvest sets, you must check from the Harvest Source.
    TEXT

    field :harvest_set, ::Types::HarvestSetType, null: true do
      description <<~TEXT
      Retrieve a single `HarvestSet` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    # @param [String] slug
    # @return [HarvestSet, nil]
    def harvest_set(slug:)
      load_record_with(::HarvestSet, slug)
    end
  end
end
