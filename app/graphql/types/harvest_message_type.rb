# frozen_string_literal: true

module Types
  # @see HarvestMessage
  class HarvestMessageType < Types::BaseModel
    description <<~TEXT
    A single log message recorded during some aspect of harvesting.
    TEXT

    field :harvest_source, "Types::HarvestSourceType", null: true do
      description <<~TEXT
      The harvest source associated with the message.
      TEXT
    end

    field :harvest_mapping, "Types::HarvestMappingType", null: true do
      description <<~TEXT
      The harvest mapping associatd with the message, if available.
      TEXT
    end

    field :harvest_attempt, "Types::HarvestAttemptType", null: true do
      description <<~TEXT
      The harvest attempt associatd with the message, if available.
      TEXT
    end

    field :harvest_record, "Types::HarvestRecordType", null: true do
      description <<~TEXT
      The harvest record associatd with the message, if available.
      TEXT
    end

    field :harvest_entity, "Types::HarvestEntityType", null: true do
      description <<~TEXT
      The harvest entity associatd with the message, if available.
      TEXT
    end

    field :at, ::GraphQL::Types::ISO8601DateTime, null: false do
      description <<~TEXT
      The time the message occurred. This field should be favored at
      for display over the model's default `createdAt` field.
      TEXT
    end

    field :level, ::Types::HarvestMessageLevelType, null: false do
      description <<~TEXT
      The level of severity of the message.
      TEXT
    end

    field :message, String, null: false do
      description <<~TEXT
      The message itself.
      TEXT
    end

    field :tags, [String, { null: false }], null: false do
      description <<~TEXT
      Tags associated with the message. This may describe what section
      of the harvesting system triggered the message, and may support
      querying in the future.
      TEXT
    end

    load_association! :harvest_source
    load_association! :harvest_mapping
    load_association! :harvest_attempt
    load_association! :harvest_record
    load_association! :harvest_entity
  end
end
