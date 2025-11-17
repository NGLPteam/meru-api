# frozen_string_literal: true

module Types
  module Schematic
    class TimestampPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType
      implements ::Types::SearchablePropertyType

      field :default, GraphQL::Types::ISO8601DateTime, null: true
      field :timestamp, GraphQL::Types::ISO8601DateTime, null: true, method: :value
    end
  end
end
