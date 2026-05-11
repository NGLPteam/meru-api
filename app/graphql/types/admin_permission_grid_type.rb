# frozen_string_literal: true

module Types
  # @see Roles::AdminPermissionGrid
  class AdminPermissionGridType < Types::BaseObject
    description <<~TEXT
    Permissions tied to the admin section of Meru.
    TEXT

    implements Types::PermissionGridType

    field :access, Boolean, null: false do
      description <<~TEXT
      A permission to access the admin section of Meru.

      This is checked in order to determine whether or not
      the client should redirect from the admin dashboard (or any admin section)
      when a user tries to access it.

      Actual access to specific admin features is determined by other permissions.
      TEXT
    end
  end
end
