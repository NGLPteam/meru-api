# frozen_string_literal: true

module Types
  module Schematic
    # @see Schemas::Properties::Scalar::Entity
    class EntityPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType
      implements ::Types::Schematic::HasAvailableEntitiesType

      description <<~TEXT
      A property that references another entity within the system.
      TEXT

      field :entity, "Types::EntityType", null: true, method: :value do
        description <<~TEXT
        A single reference to another entity within the system.
        TEXT
      end
    end
  end
end
