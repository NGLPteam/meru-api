# frozen_string_literal: true

module Types
  module Schematic
    class MultiselectPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType
      implements ::Types::Schematic::OptionablePropertyType
      implements ::Types::SearchablePropertyType

      field :default_selections, [String, { null: false }], null: true, method: :default
      field :selections, [String, { null: false }], null: true, method: :value
    end
  end
end
