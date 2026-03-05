# frozen_string_literal: true

module Types
  # @see Types::ChildEntityType
  # @see Types::ContextualPermissionType
  # @see Types::EntityContextualPermissionsType
  # @see Types::EntityType
  # @see Types::RoleType
  module ExposesPermissionsType
    include Types::BaseInterface

    description <<~TEXT
    A common interface for something that exposes contextual permissions.
    TEXT

    field :allowed_actions, [String, { null: false }], null: false do
      description "A list of allowed actions for the given user on this entity (and its descendants)."
    end

    field :permissions, [Types::PermissionGrantType, { null: false }], null: false do
      description "An array of hashes that can be requested to load in a context"
    end
  end
end
