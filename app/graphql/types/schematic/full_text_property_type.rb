# frozen_string_literal: true

module Types
  module Schematic
    class FullTextPropertyType < Types::AbstractObjectType
      implements ScalarPropertyType
      implements Types::SearchablePropertyType

      field :full_text, Types::FullTextType, null: true, method: :value
    end
  end
end
