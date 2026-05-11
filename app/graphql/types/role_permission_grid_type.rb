# frozen_string_literal: true

module Types
  # @see Roles::RolePermissionGrid
  class RolePermissionGridType < Types::BaseObject
    implements Types::PermissionGridType
    implements Types::CRUDPermissionGridType

    description <<~TEXT
    A grid of permissions related to role management in Meru.

    It lives in the `GlobalAccessControlList`.

    This does not determine anything about role _assignment_,
    for that, see the `manageAccess` permission in entity grids.
    Instead, the permissions here are solely related to managing
    role records themselves.
    TEXT
  end
end
