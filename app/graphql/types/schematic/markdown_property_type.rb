# frozen_string_literal: true

module Types
  module Schematic
    class MarkdownPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType
      implements ::Types::SearchablePropertyType

      field :default, String, null: true
      field :content, String, null: true, method: :value
    end
  end
end
