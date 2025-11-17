# frozen_string_literal: true

module Types
  module Schematic
    class URLPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType

      description "A schematic reference to a URL, with href, label, and optional title"

      field :url, Types::URLReferenceType, null: true, method: :value
    end
  end
end
