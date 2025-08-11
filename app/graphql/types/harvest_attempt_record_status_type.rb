# frozen_string_literal: true

module Types
  # @see HarvestAttemptRecordStatus
  class HarvestAttemptRecordStatusType < Types::AbstractModel
    description <<~TEXT
    A progress report for record data during a harvest attempt.
    TEXT

    field :total_records, Integer, null: true do
      description <<~TEXT
      Total number of records extracted for this attempt.
      TEXT
    end

    field :total_records_waiting_for_extraction, Integer, null: true do
      description <<~TEXT
      Total number of records that are pending extraction (which will then be harvest entities).
      TEXT
    end

    field :total_records_waiting_for_upsert, Integer, null: true do
      description <<~TEXT
      Total number of records that are waiting on their entities to be complete.
      This could include waiting for assets to be fetched.
      TEXT
    end

    field :total_records_success, Integer, null: true do
      description <<~TEXT
      Total number of records that have been successfully extracted.
      TEXT
    end

    field :extraction_duration_average, Float, null: true do
      description <<~TEXT
      Average time to extract a given record in seconds (may be used in ETA calculations in the future).
      TEXT
    end

    field :completion, Float, null: true do
      description <<~TEXT
      The percentage of completion based on current data expressed as a float between 0.0 and 1.0.
      TEXT
    end
  end
end
