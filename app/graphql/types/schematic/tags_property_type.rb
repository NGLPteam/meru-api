# frozen_string_literal: true

module Types
  module Schematic
    class TagsPropertyType < Types::AbstractObjectType
      implements ScalarPropertyType

      field :tags, [String, { null: false }], null: false, method: :value
    end
  end
end
