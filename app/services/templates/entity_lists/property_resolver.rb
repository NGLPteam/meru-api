# frozen_string_literal: true

module Templates
  module EntityLists
    # @see Templates::EntityLists::ResolveProperty
    class PropertyResolver < AbstractResolver
      option :selection_property_path, Templates::Types::String.optional, optional: true

      def resolve_entities
        property_path = yield Maybe(selection_property_path)

        reader = yield source_entity.read_property(property_path)

        case reader.type
        in "entities"
          Success reader.value
        in "entity"
          # simplecov:disable
          Success [reader.value].compact
          # simplecov:enable
        else
          # simplecov:disable
          Failure[:non_entity_property, property_path]
          # simplecov:enable
        end
      end
    end
  end
end
