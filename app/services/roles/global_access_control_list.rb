# frozen_string_literal: true

module Roles
  # @see Types::GlobalAccessControlListType
  class GlobalAccessControlList
    include Roles::ComposesGrids

    grid :admin, Roles::AdminPermissionGrid, default: false
    grid :communities, Roles::EntityPermissionGrid, default: false
    grid :contributors, Roles::ContributorPermissionGrid, default: false
    grid :roles, Roles::RolePermissionGrid, default: { read: true }
    grid :settings, Roles::SettingsGrid, default: false
    grid :users, Roles::UserPermissionGrid, default: false
  end
end
