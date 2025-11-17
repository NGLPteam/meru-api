# frozen_string_literal: true

module Types
  # An interface for querying {HarvestSource}.
  module QueriesHarvestSource
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `HarvestSource` records.
    TEXT

    field :harvest_source, ::Types::HarvestSourceType, null: true do
      description <<~TEXT
      Retrieve a single `HarvestSource` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :harvest_sources, resolver: ::Resolvers::HarvestSourceResolver

    # @param [String] slug
    # @return [HarvestSource, nil]
    def harvest_source(slug:)
      load_record_with(::HarvestSource, slug)
    end
  end
end
