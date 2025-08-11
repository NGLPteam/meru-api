# frozen_string_literal: true

module Types
  # @see HarvestAttemptEntityStatus
  class HarvestAttemptEntityStatusType < Types::AbstractModel
    description <<~TEXT
    A progress report for entity data during a harvest attempt.
    TEXT

    field :total_entities, Integer, null: true do
      description <<~TEXT
      Total number of entities extracted for this attempt.
      TEXT
    end

    field :total_entities_with_assets, Integer, null: true do
      description <<~TEXT
      Total number of entities extracted for this attempt that have 1 or more assets attached.
      TEXT
    end

    field :total_entities_waiting_for_upsert, Integer, null: true do
      description <<~TEXT
      Total number of entities that are pending upsert.
      TEXT
    end

    field :total_entities_waiting_for_assets, Integer, null: true do
      description <<~TEXT
      Total number of entities that are waiting for assets to be fetched.
      TEXT
    end

    field :total_entities_success, Integer, null: true do
      description <<~TEXT
      Total number of entities that have been successfully extracted.
      TEXT
    end

    field :upsert_duration_average, Float, null: true do
      description <<~TEXT
      Average time to upsert a given entity in seconds (may be used in ETA calculations in the future).
      TEXT
    end

    field :assets_duration_average, Float, null: true do
      description <<~TEXT
      Average time to fetch assets for a given entity in seconds (may be used in ETA calculations in the future).
      TEXT
    end

    field :upsert_eta, GraphQL::Types::ISO8601DateTime, null: true do
      description <<~TEXT
      A (very) rough estimate of when the entities might be fully upserted.
      TEXT
    end

    field :assets_eta, GraphQL::Types::ISO8601DateTime, null: true do
      description <<~TEXT
      A (very) rough estimate of when the assets might be fully extracted.
      TEXT
    end

    field :completion, Float, null: true do
      description <<~TEXT
      The percentage of completion based on current data expressed as a float between 0.0 and 1.0.
      TEXT
    end
  end
end
