# frozen_string_literal: true

module Types
  # @see Role
  class RoleType < Types::AbstractModel
    description "A named role in the Meru API"

    field :identifier, Types::RoleSystemIdentifierType, null: true do
      description <<~TEXT
      For `system` roles, this will be populated with the unique identifier
      that marks this as a system role.
      TEXT
    end

    field :name, String, null: false do
      description "The human readable name of the role within the system"
    end

    field :kind, Types::RoleKindType, null: false do
      description <<~TEXT
      The specific kind of role this is, based on how it entered the WDP-API.
      TEXT
    end

    field :access_control_list, Types::AccessControlListType, null: false do
      description "The access control list for this specific role"
    end

    field :allowed_actions, [String, { null: false }], null: false do
      description "A list of action names that have been granted to this role"
    end

    field :global_access_control_list, Types::GlobalAccessControlListType, null: false do
      description <<~TEXT
      The global access control list that this assigned role implies, based on its sort order.
      TEXT
    end

    field :global_allowed_actions, [String, { null: false }], null: false do
      description <<~TEXT
      A list of global action names that this role implies, based on its sort order.
      TEXT
    end

    field :permissions, [Types::PermissionGrantType, { null: false }], null: false do
      description <<~TEXT
      Surfaced from the accessControlList for convenience, these are returned as
      an array that allows a user to check for the state of all possible roles
      without having to specify them explicitly in the GraphQL request
      TEXT
    end

    field :custom_priority, Integer, null: true do
      description "Only relevant for `custom` roles, this affects sorting."
    end

    field :primacy, Types::RolePrimacyType, null: false do
      description <<~TEXT
      Used internally to sort roles and ensure certain role types are above
      and below others, irrespective of priority.
      TEXT
    end

    field :priority, Integer, null: false do
      description <<~TEXT
      The calculated sort priority for this role.

      * For `custom` roles, it is based on `custom_priority`.
      * For `system` roles, it is based on hard-coded values within the system
        and cannot be modified.
      TEXT
    end

    # @see Roles::AccessControlList#permissions
    # @return [<Hash>]
    def permissions
      object.access_control_list.permissions
    end
  end
end
