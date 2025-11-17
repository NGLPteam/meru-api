# frozen_string_literal: true

module Types
  module Schematic
    class SelectOptionType < Types::BaseObject
      description "An option for a select-type property."

      field :label, String, null: false do
        description "The display label for the option."
      end

      field :value, String, null: false do
        description "The underlying value for the option."
      end
    end
  end
end
