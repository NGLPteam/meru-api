# frozen_string_literal: true

module Types
  module Schematic
    module HasAvailableEntitiesType
      include Types::BaseInterface

      field :available_entities, ["Types::EntitySelectOptionType", { null: false }], null: false do
        description <<~TEXT
        Expose all available entities for this schema property.
        TEXT
      end

      # @return [<Entity>]
      def available_entities
        object.available_entities.value_or([])
      end
    end
  end
end
