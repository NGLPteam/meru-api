# frozen_string_literal: true

module Types
  # @see Roles::EntityPermissionGrid
  class EntityPermissionGridType < Types::BaseObject
    implements Types::PermissionGridType
    implements Types::CRUDPermissionGridType

    description "A grid of permissions for various hierarchical entity scopes."

    field :manage_access, Boolean, null: false do
      description <<~TEXT
      Whether the user can manage access to entities at this scope.
      TEXT
    end

    field :assets, Types::AssetPermissionGridType, null: false do
      description <<~TEXT
      Permissions related to managing assets associated with the attached entity.

      This is slated for deprecation in a future release. Instead, permissions for
      assets will be determined by the `update` permission on the entity.
      TEXT
    end
  end
end
