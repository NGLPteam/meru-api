# frozen_string_literal: true

module Types
  module Schematic
    class GroupPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType

      description <<~TEXT
      A schema property that groups other schema properties together underneath a `path`.
      TEXT

      field :legend, String, null: true do
        description "The legend / label for this group property."
      end

      field :required, Boolean, null: false do
        description "Whether this property is required to have a value."
      end

      field :properties, ["Types::Schematic::ScalarPropertyType", { null: false }], null: false do
        description "The list of (scalar) schema properties contained within this group."
      end
    end
  end
end
