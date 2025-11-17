# frozen_string_literal: true

module Types
  module Schematic
    class ContributorsPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType

      field :contributors, ["Types::ContributorType", { null: false }], null: false, method: :value
    end
  end
end
