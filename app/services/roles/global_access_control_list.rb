# frozen_string_literal: true

module Roles
  class GlobalAccessControlList
    include Roles::ComposesGrids

    grid :admin, AdminGrid, default: false
    grid :communities, EntityPermissionGrid, default: false
    grid :contributors, default: false
    grid :roles, default: { read: true }
    grid :settings, Roles::SettingsGrid, default: false
    grid :users, default: false
  end
end
