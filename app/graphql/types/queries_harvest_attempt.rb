# frozen_string_literal: true

module Types
  # An interface for querying {HarvestAttempt}.
  module QueriesHarvestAttempt
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `HarvestAttempt` records.
    TEXT

    field :harvest_attempt, ::Types::HarvestAttemptType, null: true do
      description <<~TEXT
      Retrieve a single `HarvestAttempt` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :harvest_attempts, resolver: ::Resolvers::HarvestAttemptResolver do
      description <<~TEXT
      Query all harvest attempts in the system.
      TEXT
    end

    # @param [String] slug
    # @return [HarvestAttempt, nil]
    def harvest_attempt(slug:)
      load_record_with(::HarvestAttempt, slug)
    end
  end
end
