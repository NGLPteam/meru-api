# frozen_string_literal: true

module Types
  module Schematic
    class DatePropertyType < Types::AbstractObjectType
      implements ScalarPropertyType
      implements Types::SearchablePropertyType

      field :default, GraphQL::Types::ISO8601Date, null: true
      field :date, GraphQL::Types::ISO8601Date, null: true, method: :value
    end
  end
end
