# frozen_string_literal: true

module Types
  module Schematic
    class TagsPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType

      field :tags, [String, { null: false }], null: false, method: :value
    end
  end
end
