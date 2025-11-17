# frozen_string_literal: true

module Types
  module Schematic
    class BooleanPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType
      implements Types::SearchablePropertyType

      field :checked_by_default, Boolean, null: true, method: :default
      field :checked, Boolean, null: true, method: :value
    end
  end
end
