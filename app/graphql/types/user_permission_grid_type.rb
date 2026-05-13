# frozen_string_literal: true

module Types
  class UserPermissionGridType < Types::BaseObject
    implements Types::PermissionGridType
    implements Types::CRUDPermissionGridType

    description <<~TEXT
    A grid of permissions related to user management in Meru.
    TEXT
  end
end
