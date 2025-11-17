# frozen_string_literal: true

module Types
  module Schematic
    class AssetsPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType

      field :assets, ["Types::AssetType", { null: false }], null: false, method: :value
    end
  end
end
