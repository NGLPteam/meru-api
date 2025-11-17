# frozen_string_literal: true

module Types
  class ContextualPermissionType < Types::AbstractModel
    implements Types::ExposesPermissionsType

    description "A contextual permission for a user, role, and entity"

    field :access_control_list, Types::AccessControlListType, null: true do
      description <<~TEXT
      The derived access control list for this user and entity.
      TEXT
    end

    field :access_grants, [Types::UserAccessGrantType, { null: false }], null: false do
      description <<~TEXT
      The access grants that correspond to this contextual permission.
      TEXT
    end

    field :roles, [Types::RoleType, { null: false }], null: false do
      description <<~TEXT
      The roles that correspond to this contextual permission.
      TEXT
    end

    field :user, Types::UserType, null: false do
      description <<~TEXT
      The user that has the contextual permission.
      TEXT
    end

    load_association! :access_grants
    load_association! :roles
    load_association! :user
  end
end
