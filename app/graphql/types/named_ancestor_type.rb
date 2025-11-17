# frozen_string_literal: true

module Types
  class NamedAncestorType < Types::BaseObject
    description "A named ancestor for an entity, based on the schema."

    description <<~TEXT
    Entity schemas can define named ancestors, which allows UI developers to refer
    authoritatively to significant relatives in an entity's ancestor. This object
    represents the connection between an originating entity and its ancestors,
    should any be defined for the schema.
    TEXT

    field :name, String, null: false do
      description "The name of the ancestor. Guaranteed to be unique for this specific entity."
    end

    field :ancestor, Types::EntityType, null: false do
      description "The actual ancestor"
    end

    field :relative_depth, Integer, null: false do
      description <<~TEXT
      The relative depth from the source entity to its ancestor. In other words, `(origin_depth - ancestor_depth)`.
      Used for sorting ancestors deterministically.
      TEXT
    end

    field :origin_depth, Integer, null: false do
      description "The relative depth of the originating entity"
    end

    field :ancestor_depth, Integer, null: false do
      description "The depth of the ancestor in the hierarchy"
    end
  end
end
