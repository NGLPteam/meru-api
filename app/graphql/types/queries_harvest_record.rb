# frozen_string_literal: true

module Types
  # An interface for querying {HarvestRecord}.
  module QueriesHarvestRecord
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `HarvestRecord` records.
    TEXT

    field :harvest_record, ::Types::HarvestRecordType, null: true do
      description <<~TEXT
      Retrieve a single `HarvestRecord` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :harvest_records, resolver: ::Resolvers::HarvestRecordResolver do
      description <<~TEXT
      Query all harvest records in the system.
      TEXT
    end

    # @param [String] slug
    # @return [HarvestRecord, nil]
    def harvest_record(slug:)
      load_record_with(::HarvestRecord, slug)
    end
  end
end
