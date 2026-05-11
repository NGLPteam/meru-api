# frozen_string_literal: true

module Types
  # @see HarvestMapping
  class HarvestMappingType < Types::BaseModel
    description <<~TEXT
    A specific mapping to be used by a `HarvestSource`,
    possibly an optional `HarvestSet`, and other options
    in order to harvest records from the source and produce
    entities.

    It can produce a `HarvestAttempt`.
    TEXT

    implements Types::HarvestAttemptableType
    implements Types::HasHarvestExtractionMappingTemplateType
    implements Types::HasHarvestMetadataFormatType
    implements Types::HasHarvestOptionsType
    implements Types::QueriesHarvestMessage

    field :harvest_source, "Types::HarvestSourceType", null: false do
      description <<~TEXT
      The harvest source this belongs to.
      TEXT
    end

    field :harvest_attempts, resolver: ::Resolvers::HarvestAttemptResolver do
      description <<~TEXT
      Attempts produced by this mapping.
      TEXT
    end

    field :harvest_records, resolver: ::Resolvers::HarvestRecordResolver do
      description <<~TEXT
      Records associated with this mapping.
      TEXT
    end

    field :harvest_set, Types::HarvestSetType, null: true do
      description <<~TEXT
      The optionally-associated harvest set for this mapping.
      TEXT
    end

    field :target_entity, ::Types::HarvestTargetType, null: false do
      description <<~TEXT
      The target entity for the attempt. All harvest entities will be nested under this entity, unless otherwise specified.
      TEXT
    end

    field :mode, ::Types::HarvestScheduleModeType, null: false do
      description <<~TEXT
      Whether this mapping is `MANUAL` or `SCHEDULED`. This field is not set
      through the admin section, but derived from parsing the mapping's
      `frequencyExpression`.

      `SCHEDULED` mappings will automatically create `HarvestAttempt`s
      for the next several iterations of their `frequencyExpression`.
      TEXT
    end

    field :frequency_expression, String, null: true do
      description <<~TEXT
      This can be a cron expression as well as a human-readable expression like
      `"every sunday at 5 am America/Los_Angeles"`.
      The system will attempt to validate and parse the expression when setting
      it in order to make sure it is something that Meru can handle.
      TEXT
    end

    field :schedule_data, ::Types::HarvestScheduleDataType, null: false do
      description <<~TEXT
      Derived information about the frequency expression (if valid and applicable),
      to provide insight for introspection.
      TEXT
    end

    field :last_scheduled_at, GraphQL::Types::ISO8601DateTime, null: true do
      description <<~TEXT
      This timestamp signifies when the harvest mapping last tried to schedule its
      attempts (if applicable).
      TEXT
    end

    field :schedule_changed_at, GraphQL::Types::ISO8601DateTime, null: true do
      description <<~TEXT
      This timestamp signifies the last time the frequency expression, or any
      of its derived fields, were changed.
      TEXT
    end

    load_association! :harvest_source
    load_association! :target_entity
  end
end
