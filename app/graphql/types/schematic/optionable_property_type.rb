# frozen_string_literal: true

module Types
  module Schematic
    module OptionablePropertyType
      include ::Types::BaseInterface

      description <<~TEXT
      An interface for properties that have a set of predefined options to choose from.
      TEXT

      field :options, [SelectOptionType, { null: false }], null: false do
        description "The list of predefined options available for this property."
      end
    end
  end
end
