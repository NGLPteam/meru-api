# frozen_string_literal: true

module Types
  # Loads {ContextualPermission} information for a {HierarchicalEntity}.
  #
  # @see Types::ChildEntityType
  # @see Types::EntityType
  module EntityContextualPermissionsType
    include Types::BaseInterface

    implements ::Types::ExposesPermissionsType

    field :applicable_roles, [Types::RoleType, { null: false }], null: false do
      description "The role(s) that gave the permissions to access this resource, if any."
    end

    field :assignable_roles, [Types::RoleType, { null: false }], null: false do
      description "The role(s) that the current user could assign to other users on this entity, if applicable."
    end

    # @return [ContextualPermission]
    def contextual_permission
      if context[:current_user].anonymous?
        return ContextualPermission.empty_permission_for(context[:current_user], object)
      end

      load_record_with(::ContextualPermission, object.id, find_by: :hierarchical_id, where: { user: context[:current_user] })
    end

    # This surfaces the `allowed_actions` from the associated {#contextual_permission}.
    #
    # @see ContextualPermission#allowed_actions
    # @return [String]
    def allowed_actions
      contextual_permission.then(&:allowed_actions)
    end

    # @return [Role]
    def assignable_roles
      contextual_permission.then(&:assignable_roles)
    end

    # @return [<Role>]
    def applicable_roles
      contextual_permission.then(&:roles)
    end

    # @return [<Permissions::Grant>]
    def permissions
      contextual_permission.then(&:permissions)
    end
  end
end
