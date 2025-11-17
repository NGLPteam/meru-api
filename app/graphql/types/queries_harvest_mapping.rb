# frozen_string_literal: true

module Types
  # An interface for querying {HarvestMapping}.
  module QueriesHarvestMapping
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `HarvestMapping` records.
    TEXT

    field :harvest_mapping, ::Types::HarvestMappingType, null: true do
      description <<~TEXT
      Retrieve a single `HarvestMapping` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :harvest_mappings, resolver: ::Resolvers::HarvestMappingResolver do
      description <<~TEXT
      Query all harvest mappings in the system.
      TEXT
    end

    # @param [String] slug
    # @return [HarvestMapping, nil]
    def harvest_mapping(slug:)
      load_record_with(::HarvestMapping, slug)
    end
  end
end
