# frozen_string_literal: true

module Types
  module Schematic
    class UnknownPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType

      field :default, GraphQL::Types::JSON, null: true
      field :unknown_value, GraphQL::Types::JSON, null: true, method: :value
    end
  end
end
