# frozen_string_literal: true

module Types
  # @note This interface exists to be able to DRY up adding timestamps
  #   to types that do not inherit from {Types::AbstractModelType}.
  module HasDefaultTimestampsType
    include Types::BaseInterface

    description <<~TEXT
    Automatically-set timestamps present on most real models in the system.
    TEXT

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false do
      description "The date this record was created within the API."
    end

    field :created_on, GraphQL::Types::ISO8601Date, null: false do
      description "The date this record was created within the API (date only)."
    end

    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false do
      description "The date this record was last updated within the API."
    end

    field :updated_on, GraphQL::Types::ISO8601Date, null: false do
      description "The date this record was last updated within the API (date only)."
    end

    def created_on = object.created_at.to_date

    def updated_on = object.updated_at.to_date
  end
end
