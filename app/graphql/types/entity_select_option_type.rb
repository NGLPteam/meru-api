# frozen_string_literal: true

module Types
  # A polymorphic way of accessing {HierarchicalEntity an entity}.
  class EntitySelectOptionType < Types::BaseObject
    implements Types::HasEntityBreadcrumbs

    description "A select option for a single entity"

    field :label, String, null: false, method: :to_schematic_referent_label

    field :value, ID, null: false, method: :to_schematic_referent_value

    field :slug, Types::SlugType, null: false, method: :system_slug

    field :kind, Types::EntityKindType, null: false, method: :to_schematic_referent_kind

    field :entity, "Types::EntityType", null: false

    field :schema_version, "Types::SchemaVersionType", null: false

    load_association! :schema_version

    # @return [HierarchicalEntity]
    def entity
      case object
      when ::HierarchicalEntity then object
      when ::Entity then object.hierarchical
      when ::EntityDescendant then object.descendant
      else
        # :nocov:
        raise GraphQL::ExecutionError, "can't get entity from #{object.class.name}"
        # :nocov:
      end
    end
  end
end
