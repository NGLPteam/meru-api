# frozen_string_literal: true

module Types
  module SearchablePropertyType
    include Types::BaseInterface

    description <<~TEXT
    An interface for properties that can be searched.
    TEXT

    field :label, String, null: false
    field :description, String, null: true
    field :search_path, String, null: false
    field :search_operators, [Types::SearchOperatorType, { null: false }], null: false
  end
end
