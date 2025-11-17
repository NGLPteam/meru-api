# frozen_string_literal: true

module Types
  module Schematic
    class VariableDatePropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType
      implements ::Types::SearchablePropertyType

      field :date_with_precision, ::Types::VariablePrecisionDateType, null: true, method: :value
    end
  end
end
