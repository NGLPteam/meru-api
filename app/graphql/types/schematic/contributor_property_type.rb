# frozen_string_literal: true

module Types
  module Schematic
    class ContributorPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType

      field :contributor, "Types::ContributorType", null: true, method: :value
    end
  end
end
