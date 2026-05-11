# frozen_string_literal: true

module Types
  # @see Roles::GlobalAccessControlList
  class GlobalAccessControlListType < Types::BaseObject
    implements Types::ExposesPermissionsType

    description <<~TEXT
    A global ACL that applies to a given role.

    Permissions defined in this ACL are not scoped to any particular entity.
    TEXT

    field :admin, Types::AdminPermissionGridType, null: false do
      description <<~TEXT
      Permissions related to the admin section of Meru.
      TEXT
    end

    field :communities, Types::EntityPermissionGridType, null: false do
      description <<~TEXT
      Permissions related to communities, aka top-level entities.
      TEXT
    end

    field :contributors, Types::ContributorPermissionGridType, null: false do
      description <<~TEXT
      Permissions related to contributors.
      TEXT
    end

    field :roles, Types::RolePermissionGridType, null: false do
      description <<~TEXT
      Permissions related to managing role records in Meru.
      TEXT
    end

    field :settings, Types::SettingsPermissionGridType, null: false do
      description <<~TEXT
      Permissions related to managing global configuration settings in Meru.
      TEXT
    end

    field :users, Types::UserPermissionGridType, null: false do
      description <<~TEXT
      Permissions related to managing user records in Meru.
      TEXT
    end
  end
end
