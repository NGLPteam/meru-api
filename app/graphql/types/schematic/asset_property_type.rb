# frozen_string_literal: true

module Types
  module Schematic
    class AssetPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType

      field :asset, "Types::AssetType", null: true, method: :value
    end
  end
end
