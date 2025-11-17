# frozen_string_literal: true

module Types
  # A GraphQL representation for {EntityDescendant}.
  class EntityDescendantType < Types::BaseObject
    description "A descendant of an `Entity`."

    field :descendant, "Types::EntityType", null: false do
      description "The actual descendant entity"
    end

    field :relative_depth, Integer, null: false do
      description "The relative depth of this entity from its ancestor"
    end

    field :scope, Types::EntityScopeType, null: false do
      description "The scope of this entity relative to its ancestor"
    end

    load_association! :descendant
  end
end
