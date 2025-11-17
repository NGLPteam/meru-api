# frozen_string_literal: true

module Types
  module Schematic
    class SelectPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType
      implements ::Types::Schematic::OptionablePropertyType
      implements Types::SearchablePropertyType

      field :default_selection, String, null: true, method: :default
      field :selection, String, null: true, method: :value
    end
  end
end
